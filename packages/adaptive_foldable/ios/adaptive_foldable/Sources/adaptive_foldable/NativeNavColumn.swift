import Flutter
import UIKit

/// Liquid Glass side column for iPhone Duo: Back, actions and an icon-only tab capsule.
///
/// Mirrors the system's vertical bars: separate glass circles for single
/// controls, one capsule per action group, one capsule for the tabs lower in
/// the column. Dart stays the source of truth; every tap is sent back by id.
final class NativeNavColumnView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let top = UIStackView()
  private let bottom = UIStackView()
  private let channel: FlutterMethodChannel

  init(frame: CGRect, channel: FlutterMethodChannel, params: [String: Any]?) {
    self.channel = channel
    super.init()
    container.frame = frame
    for stack in [top, bottom] {
      stack.axis = .vertical
      stack.alignment = .center
      stack.spacing = 12
      stack.translatesAutoresizingMaskIntoConstraints = false
      container.addSubview(stack)
      stack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    }
    NSLayoutConstraint.activate([
      top.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
      bottom.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
      top.bottomAnchor.constraint(lessThanOrEqualTo: bottom.topAnchor, constant: -12),
    ])
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let args = call.arguments as? [String: Any] {
        self?.apply(args)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    if let params = params { apply(params) }
  }

  deinit { channel.setMethodCallHandler(nil) }

  func view() -> UIView { container }

  func apply(_ params: [String: Any]) {
    for stack in [top, bottom] {
      stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    let groups = params["groups"] as? [[String: Any]] ?? []
    for group in groups {
      let items = group["items"] as? [[String: Any]] ?? []
      let isTabs = group["role"] as? String == "tabs"
      (isTabs ? bottom : top).addArrangedSubview(makeGlass(items))
    }
    top.alpha = CGFloat((params["actionsOpacity"] as? NSNumber)?.doubleValue ?? 1)
    top.isUserInteractionEnabled = top.alpha >= 0.5
  }

  private func makeGlass(_ items: [[String: Any]]) -> UIView {
    let glass = GlassPillView()
    let stack = UIStackView(arrangedSubviews: items.map(makeButton))
    stack.axis = .vertical
    stack.translatesAutoresizingMaskIntoConstraints = false
    glass.contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: glass.contentView.topAnchor, constant: 4),
      stack.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor, constant: -4),
      stack.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor, constant: 4),
      stack.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor, constant: -4),
    ])
    return glass
  }

  private func image(_ item: [String: Any]) -> UIImage? {
    let selected = item["selected"] as? Bool ?? false
    if let symbol = item["sfSymbol"] as? String {
      return UIImage(systemName: symbol)
    }
    let key = selected && item["selectedIcon"] != nil ? "selectedIcon" : "icon"
    guard let data = (item[key] as? FlutterStandardTypedData)?.data,
      let png = UIImage(data: data, scale: 3)
    else { return nil }
    return png.withRenderingMode(.alwaysTemplate)
  }

  private func makeButton(_ item: [String: Any]) -> UIView {
    let id = item["id"] as? String ?? ""
    let selected = item["selected"] as? Bool ?? false
    let destructive = item["destructive"] as? Bool ?? false
    let isTab = id.hasPrefix("tab:")

    var config = UIButton.Configuration.plain()
    config.image = image(item)
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
    config.baseForegroundColor = destructive ? .systemRed : (selected ? .tintColor : .label)
    if selected {
      config.background.backgroundColor = UIColor.tintColor.withAlphaComponent(isTab ? 0.18 : 0.12)
      config.background.cornerRadius = 22
    }
    let button = UIButton(configuration: config)
    button.isEnabled = item["enabled"] as? Bool ?? true
    button.accessibilityLabel = item["label"] as? String
    button.accessibilityValue = item["badgeLabel"] as? String
    button.accessibilityTraits = selected ? [.button, .selected] : .button
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(equalToConstant: 44),
      button.heightAnchor.constraint(equalToConstant: 44),
    ])
    button.addAction(
      UIAction { [weak self, weak button] _ in
        guard let self = self, let button = button else { return }
        let frame = button.convert(button.bounds, to: nil)
        self.channel.invokeMethod(
          "onTap",
          arguments: [
            "id": id,
            "rect": [frame.origin.x, frame.origin.y, frame.width, frame.height],
          ]
        )
      },
      for: .touchUpInside
    )
    if let badge = item["badge"] as? Int, badge > 0 {
      addBadge(badge > 99 ? "99+" : String(badge), to: button)
    }
    return button
  }

  private func addBadge(_ text: String, to button: UIButton) {
    let label = UILabel()
    label.text = " \(text) "
    label.font = .systemFont(ofSize: 11, weight: .semibold)
    label.textColor = .white
    label.backgroundColor = .systemRed
    label.layer.cornerRadius = 8
    label.layer.masksToBounds = true
    label.isAccessibilityElement = false
    label.translatesAutoresizingMaskIntoConstraints = false
    button.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: button.topAnchor, constant: 2),
      label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2),
      label.heightAnchor.constraint(equalToConstant: 16),
    ])
  }
}

/// A capsule of Liquid Glass (iOS 26+) or a system blur on older systems.
final class GlassPillView: UIVisualEffectView {
  init() {
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = true
      super.init(effect: glass)
      cornerConfiguration = .capsule()
    } else {
      super.init(effect: UIBlurEffect(style: .systemThinMaterial))
      layer.masksToBounds = true
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

  override func layoutSubviews() {
    super.layoutSubviews()
    if #unavailable(iOS 26.0) {
      layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
  }
}
