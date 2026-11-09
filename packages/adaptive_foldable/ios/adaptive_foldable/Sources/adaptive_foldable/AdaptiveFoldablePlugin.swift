import Flutter
import UIKit

public struct RegionData: Equatable {
  public let kind: String // "division" or "occlusion"
  public let rect: CGRect
  public let isActive: Bool

  public init(kind: String, rect: CGRect, isActive: Bool) {
    self.kind = kind
    self.rect = rect
    self.isActive = isActive
  }
}

public class AdaptiveFoldablePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private weak var registrar: FlutterPluginRegistrar?
  private var observationView: AdaptiveFoldableObservationView?
  private var traitRegistration: Any?
  private var currentPosture: String = "unknown"
  private var lastEmittedPayload: [String: Any]?

  #if canImport(UIKit, _version: "9127.0.85")
  private var hingeInteraction: Any?
  #endif

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: "dev.adaptivefoldable/signals",
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: "dev.adaptivefoldable/signals/events",
      binaryMessenger: registrar.messenger()
    )

    let instance = AdaptiveFoldablePlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)

    DispatchQueue.main.async {
      instance.setupViewObservation()
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSignals":
      result(currentPayload())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    let payload = currentPayload()
    lastEmittedPayload = payload
    events(payload)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  public func emitCurrentSignals() {
    guard let eventSink = self.eventSink else { return }
    let payload = currentPayload()
    if let last = lastEmittedPayload, isPayloadEqual(last, payload) {
      return
    }
    lastEmittedPayload = payload
    eventSink(payload)
  }

  public func currentPayload() -> [String: Any] {
    let view = registrar?.viewController?.view
    let traitCollection = view?.traitCollection ?? registrar?.viewController?.traitCollection ?? UITraitCollection.current
    let viewSize = view?.bounds.size ?? .zero

    let barEdge: String?
    var regionData: [RegionData] = []
    #if canImport(UIKit, _version: "9127.0.85")
    barEdge = SignalsPayloadBuilder.resolveBarEdge(from: traitCollection)
    let sdk271 = true
    if #available(iOS 27.1, *), let view = view {
      let divisions = view.reservedRegions(kind: .division)
      for r in divisions {
        regionData.append(RegionData(kind: "division", rect: r.frame, isActive: r.isActive))
      }
      let occlusions = view.reservedRegions(kind: .occlusion)
      for r in occlusions {
        regionData.append(RegionData(kind: "occlusion", rect: r.frame, isActive: r.isActive))
      }
    }
    #else
    barEdge = nil
    let sdk271 = false
    #endif

    let filtered = SignalsPayloadBuilder.filterRegions(
      regions: regionData,
      posture: currentPosture
    )

    return SignalsPayloadBuilder.build(
      viewSize: viewSize,
      horizontalSizeClass: traitCollection.horizontalSizeClass,
      verticalSizeClass: traitCollection.verticalSizeClass,
      verticalBarEdge: barEdge,
      activeFolds: filtered.folds,
      occlusions: filtered.occlusions,
      posture: currentPosture,
      isAvailable: true,
      sdk271: sdk271
    )
  }

  @MainActor
  private func setupViewObservation() {
    guard let vc = registrar?.viewController else { return }

    if #available(iOS 17.0, *) {
      var traits: [UITrait] = [
        UITraitHorizontalSizeClass.self,
        UITraitVerticalSizeClass.self,
        UITraitLayoutDirection.self,
      ]
      #if canImport(UIKit, _version: "9127.0.85")
      if #available(iOS 27.1, *) {
        traits.append(contentsOf: UITraitCollection.systemTraitsAffectingVerticalBarEdge)
      }
      #endif
      traitRegistration = vc.registerForTraitChanges(traits) { [weak self] (_: UITraitEnvironment, _: UITraitCollection) in
        self?.emitCurrentSignals()
      }
    }

    #if canImport(UIKit, _version: "9127.0.85")
    if #available(iOS 27.1, *) {
      let hinge = UIHingeInteraction { [weak self] _, update in
        guard let self = self else { return }
        let newStatus: String
        switch update.hinge?.status {
        case .closed:
          newStatus = "closed"
        case .partiallyOpen:
          newStatus = "partiallyOpen"
        case .fullyOpen:
          newStatus = "fullyOpen"
        default:
          newStatus = "unknown"
        }
        self.currentPosture = newStatus
        self.emitCurrentSignals()
      }
      vc.view.addInteraction(hinge)
      self.hingeInteraction = hinge
    }
    #endif

    if observationView == nil, let superview = vc.view {
      let obs = AdaptiveFoldableObservationView()
      obs.isUserInteractionEnabled = false
      obs.isHidden = false
      obs.backgroundColor = .clear
      obs.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      obs.frame = superview.bounds
      obs.onLayout = { [weak self] in
        self?.emitCurrentSignals()
      }
      superview.addSubview(obs)
      observationView = obs
    }

    emitCurrentSignals()
  }

  public func detachFromView() {
    observationView?.removeFromSuperview()
    observationView = nil
    traitRegistration = nil
    #if canImport(UIKit, _version: "9127.0.85")
    if #available(iOS 27.1, *), let interaction = hingeInteraction as? UIInteraction, let view = registrar?.viewController?.view {
      view.removeInteraction(interaction)
      hingeInteraction = nil
    }
    #endif
  }

  private func isPayloadEqual(_ a: [String: Any], _ b: [String: Any]) -> Bool {
    return NSDictionary(dictionary: a).isEqual(to: b)
  }
}

class AdaptiveFoldableObservationView: UIView {
  var onLayout: (() -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    onLayout?()
  }
}

public struct SignalsPayloadBuilder {
  #if canImport(UIKit, _version: "9127.0.85")
  public static func resolveBarEdge(from traitCollection: UITraitCollection) -> String? {
    if #available(iOS 27.1, *) {
      switch traitCollection.verticalBarEdge {
      case .leading:
        return traitCollection.layoutDirection == .rightToLeft ? "right" : "left"
      case .trailing:
        return traitCollection.layoutDirection == .rightToLeft ? "left" : "right"
      case .unspecified:
        return nil
      @unknown default:
        return nil
      }
    }
    return nil
  }
  #endif

  /// Filters regions according to the four bridge rules.
  public static func filterRegions(
    regions: [RegionData],
    posture: String
  ) -> (folds: [CGRect], occlusions: [CGRect]) {
    var folds: [CGRect] = []
    var occlusions: [CGRect] = []

    for region in regions {
      // Rule 3: Never publish a zero-width, zero-height, or inactive region.
      guard region.isActive, region.rect.width > 0, region.rect.height > 0 else {
        continue
      }

      if region.kind == "division" {
        // Rule 4: Nothing while closed (cover display has no fold).
        // Rule 1: Posture, not isActive, decides whether the fold is in effect.
        if posture == "partiallyOpen" {
          folds.append(region.rect)
        }
      } else if region.kind == "occlusion" {
        // Occlusion regions (e.g. camera cutouts) apply across all postures including cover display.
        occlusions.append(region.rect)
      }
    }

    return (folds, occlusions)
  }

  public static func build(
    viewSize: CGSize,
    horizontalSizeClass: UIUserInterfaceSizeClass,
    verticalSizeClass: UIUserInterfaceSizeClass,
    verticalBarEdge: String?,
    activeFolds: [CGRect] = [],
    occlusions: [CGRect] = [],
    posture: String = "unknown",
    isAvailable: Bool = true,
    sdk271: Bool = false
  ) -> [String: Any] {
    let hSize: String
    switch horizontalSizeClass {
    case .compact:
      hSize = "compact"
    case .regular:
      hSize = "regular"
    default:
      hSize = "unknown"
    }

    let vSize: String
    switch verticalSizeClass {
    case .compact:
      vSize = "compact"
    case .regular:
      vSize = "regular"
    default:
      vSize = "unknown"
    }

    var payload: [String: Any] = [
      "viewSize": [
        "width": Double(viewSize.width),
        "height": Double(viewSize.height),
      ],
      "horizontalSizeClass": hSize,
      "verticalSizeClass": vSize,
      "posture": posture,
      "isAvailable": isAvailable,
      "sdk271": sdk271,
      "activeFolds": activeFolds.map { r in
        [
          "x": Double(r.origin.x),
          "y": Double(r.origin.y),
          "width": Double(r.size.width),
          "height": Double(r.size.height),
        ]
      },
      "occlusions": occlusions.map { r in
        [
          "x": Double(r.origin.x),
          "y": Double(r.origin.y),
          "width": Double(r.size.width),
          "height": Double(r.size.height),
        ]
      },
    ]

    if let edge = verticalBarEdge {
      payload["verticalBarEdge"] = edge
    } else {
      payload["verticalBarEdge"] = NSNull()
    }

    return payload
  }
}


