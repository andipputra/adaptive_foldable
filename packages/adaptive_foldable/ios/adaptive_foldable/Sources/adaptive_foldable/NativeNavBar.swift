import Flutter
import UIKit

/// Creates `UITabBar` platform views for `nativeIosBarBuilder`.
final class NativeNavBarFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    NativeNavBarView(frame: frame, viewId: viewId, messenger: messenger, params: args as? [String: Any])
  }
}

/// A tab bar whose selection round-trips through Dart; Dart stays the source of truth.
final class NativeNavBarView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let tabBar = UITabBar()
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private var selectedIndex = 0

  init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, params: [String: Any]?) {
    channel = FlutterMethodChannel(
      name: "dev.adaptivefoldable/native_bar/\(viewId)",
      binaryMessenger: messenger
    )
    super.init()
    container.frame = frame
    tabBar.delegate = self
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      tabBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      tabBar.topAnchor.constraint(equalTo: container.topAnchor),
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

  func view() -> UIView { container }

  private func image(_ item: [String: Any], key: String, scale: CGFloat) -> UIImage? {
    if let symbol = item["sfSymbol"] as? String {
      return UIImage(systemName: symbol)
    }
    guard let data = (item[key] as? FlutterStandardTypedData)?.data ?? (item["icon"] as? FlutterStandardTypedData)?.data,
      let png = UIImage(data: data, scale: 3)
    else { return nil }
    return png.withRenderingMode(.alwaysTemplate)
  }

  private func apply(_ params: [String: Any]) {
    let items = params["items"] as? [[String: Any]] ?? []
    tabBar.items = items.enumerated().map { index, item in
      let tab = UITabBarItem(
        title: item["label"] as? String,
        image: image(item, key: "icon", scale: 3),
        tag: index
      )
      tab.selectedImage = image(item, key: "selectedIcon", scale: 3)
      if let badge = item["badge"] as? Int, badge > 0 {
        tab.badgeValue = badge > 99 ? "99+" : String(badge)
      }
      return tab
    }
    selectedIndex = params["selectedIndex"] as? Int ?? 0
    if let tabs = tabBar.items, selectedIndex >= 0, selectedIndex < tabs.count {
      tabBar.selectedItem = tabs[selectedIndex]
    }
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    channel.invokeMethod("onSelected", arguments: item.tag)
  }
}
