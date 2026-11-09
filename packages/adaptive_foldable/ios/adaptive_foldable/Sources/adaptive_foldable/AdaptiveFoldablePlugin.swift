import Flutter
import UIKit

public class AdaptiveFoldablePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private weak var registrar: FlutterPluginRegistrar?
  private var observationView: AdaptiveFoldableObservationView?
  private var traitRegistration: Any?

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
    events(currentPayload())
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  public func emitCurrentSignals() {
    guard let eventSink = self.eventSink else { return }
    eventSink(currentPayload())
  }

  public func currentPayload() -> [String: Any] {
    let view = registrar?.viewController?.view
    let traitCollection = view?.traitCollection ?? registrar?.viewController?.traitCollection ?? UITraitCollection.current
    let viewSize = view?.bounds.size ?? .zero

    let barEdge: String?
    #if canImport(UIKit, _version: "9127.0.85")
    barEdge = SignalsPayloadBuilder.resolveBarEdge(from: traitCollection)
    let sdk271 = true
    #else
    barEdge = nil
    let sdk271 = false
    #endif

    return SignalsPayloadBuilder.build(
      viewSize: viewSize,
      horizontalSizeClass: traitCollection.horizontalSizeClass,
      verticalSizeClass: traitCollection.verticalSizeClass,
      verticalBarEdge: barEdge,
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

  public static func build(
    viewSize: CGSize,
    horizontalSizeClass: UIUserInterfaceSizeClass,
    verticalSizeClass: UIUserInterfaceSizeClass,
    verticalBarEdge: String?,
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
      "isAvailable": isAvailable,
      "sdk271": sdk271,
    ]

    if let edge = verticalBarEdge {
      payload["verticalBarEdge"] = edge
    } else {
      payload["verticalBarEdge"] = NSNull()
    }

    return payload
  }
}

