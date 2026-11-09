import Flutter
import UIKit
import XCTest

@testable import adaptive_foldable

class RunnerTests: XCTestCase {
  func testSignalsPayloadBuilderRegularCompact() {
    let payload = SignalsPayloadBuilder.build(
      viewSize: CGSize(width: 800, height: 600),
      horizontalSizeClass: .regular,
      verticalSizeClass: .compact,
      verticalBarEdge: "right",
      isAvailable: true,
      sdk271: true
    )

    XCTAssertEqual(payload["horizontalSizeClass"] as? String, "regular")
    XCTAssertEqual(payload["verticalSizeClass"] as? String, "compact")
    XCTAssertEqual(payload["verticalBarEdge"] as? String, "right")
    XCTAssertEqual(payload["isAvailable"] as? Bool, true)
    XCTAssertEqual(payload["sdk271"] as? Bool, true)

    if let size = payload["viewSize"] as? [String: Double] {
      XCTAssertEqual(size["width"], 800.0)
      XCTAssertEqual(size["height"], 600.0)
    } else {
      XCTFail("Missing or invalid viewSize in payload")
    }
  }

  func testSignalsPayloadBuilderNullEdge() {
    let payload = SignalsPayloadBuilder.build(
      viewSize: CGSize(width: 400, height: 800),
      horizontalSizeClass: .compact,
      verticalSizeClass: .regular,
      verticalBarEdge: nil,
      isAvailable: true,
      sdk271: false
    )

    XCTAssertTrue(payload["verticalBarEdge"] is NSNull)
    XCTAssertEqual(payload["horizontalSizeClass"] as? String, "compact")
    XCTAssertEqual(payload["verticalSizeClass"] as? String, "regular")
    XCTAssertEqual(payload["sdk271"] as? Bool, false)
  }

  func testMethodChannelGetSignals() {
    let plugin = AdaptiveFoldablePlugin()
    let call = FlutterMethodCall(methodName: "getSignals", arguments: nil)

    let expectation = self.expectation(description: "getSignals callback")
    plugin.handle(call) { result in
      guard let payload = result as? [String: Any] else {
        XCTFail("Result should be a dictionary")
        return
      }
      XCTAssertNotNil(payload["horizontalSizeClass"])
      XCTAssertNotNil(payload["verticalSizeClass"])
      XCTAssertNotNil(payload["viewSize"])
      XCTAssertNotNil(payload["isAvailable"])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0)
  }
}

