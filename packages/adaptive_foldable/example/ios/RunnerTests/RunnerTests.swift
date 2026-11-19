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
      activeFolds: [CGRect(x: 380, y: 0, width: 40, height: 600)],
      occlusions: [CGRect(x: 0, y: 0, width: 50, height: 30)],
      posture: "partiallyOpen",
      isAvailable: true,
      sdk271: true
    )

    XCTAssertEqual(payload["horizontalSizeClass"] as? String, "regular")
    XCTAssertEqual(payload["verticalSizeClass"] as? String, "compact")
    XCTAssertEqual(payload["verticalBarEdge"] as? String, "right")
    XCTAssertEqual(payload["posture"] as? String, "partiallyOpen")
    XCTAssertEqual(payload["isAvailable"] as? Bool, true)
    XCTAssertEqual(payload["sdk271"] as? Bool, true)

    let folds = payload["activeFolds"] as? [[String: Any]]
    XCTAssertEqual(folds?.count, 1)
    XCTAssertEqual(folds?.first?["width"] as? Double, 40.0)

    let occlusions = payload["occlusions"] as? [[String: Any]]
    XCTAssertEqual(occlusions?.count, 1)
    XCTAssertEqual(occlusions?.first?["width"] as? Double, 50.0)

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

  func testRule3ZeroWidthAndInactiveDropped() {
    let regions = [
      RegionData(kind: "division", rect: CGRect(x: 400, y: 0, width: 0, height: 600), isActive: true),
      RegionData(kind: "division", rect: CGRect(x: 400, y: 0, width: 40, height: 600), isActive: false),
      RegionData(kind: "occlusion", rect: CGRect(x: 0, y: 0, width: 0, height: 30), isActive: true),
      RegionData(kind: "occlusion", rect: CGRect(x: 0, y: 0, width: 50, height: 30), isActive: false),
    ]

    let result = SignalsPayloadBuilder.filterRegions(regions: regions, posture: "partiallyOpen")
    XCTAssertTrue(result.folds.isEmpty, "Zero-width and inactive folds must be dropped (Rule 3)")
    XCTAssertTrue(result.occlusions.isEmpty, "Zero-width and inactive occlusions must be dropped (Rule 3)")
  }

  func testRule4NothingWhileClosedExceptCameraOcclusion() {
    let regions = [
      RegionData(kind: "division", rect: CGRect(x: 400, y: 0, width: 40, height: 600), isActive: true),
      RegionData(kind: "occlusion", rect: CGRect(x: 180, y: 0, width: 54, height: 30), isActive: true),
    ]

    let result = SignalsPayloadBuilder.filterRegions(regions: regions, posture: "closed")
    XCTAssertTrue(result.folds.isEmpty, "No folds while closed on cover display (Rule 4)")
    XCTAssertEqual(result.occlusions.count, 1, "Camera occlusion must still be reported while closed")
  }

  func testRule1PostureWinsOverIsActive() {
    // Device is fully open flat, but reserved region is still reporting active (3-14ms lag)
    let regions = [
      RegionData(kind: "division", rect: CGRect(x: 455.5, y: 0, width: 40, height: 669), isActive: true),
    ]

    let result = SignalsPayloadBuilder.filterRegions(regions: regions, posture: "fullyOpen")
    XCTAssertTrue(result.folds.isEmpty, "Posture fullyOpen wins over active region (Rule 1)")
  }

  func testPartiallyOpenFoldsKept() {
    let regions = [
      RegionData(kind: "division", rect: CGRect(x: 455.5, y: 0, width: 40, height: 669), isActive: true),
      RegionData(kind: "occlusion", rect: CGRect(x: 451, y: 0, width: 49, height: 25), isActive: true),
    ]

    let result = SignalsPayloadBuilder.filterRegions(regions: regions, posture: "partiallyOpen")
    XCTAssertEqual(result.folds.count, 1)
    XCTAssertEqual(result.folds.first?.width, 40)
    XCTAssertEqual(result.occlusions.count, 1)
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
      XCTAssertNotNil(payload["activeFolds"])
      XCTAssertNotNil(payload["occlusions"])
      XCTAssertNotNil(payload["posture"])
      XCTAssertNotNil(payload["isAvailable"])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1.0)
  }
}


