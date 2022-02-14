//
//  BuildersTests.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay


class FailureBuilderTests : XCTestCase {
  func testFailure() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)
    let error = NSError(domain: "MockingjayTests", code: 0, userInfo: nil)
    
    let response = failure(error)(request)
    
    XCTAssertEqual(response, Response.failure(error))
  }

  func testUnspecifiedFailure() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)

    let response = failure()(request)

    switch response {
    case .success(_, _):
      XCTFail("Unexpected success")
    case .failure(_):
      break
    }
  }
  
  func testHTTP() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)
    
    let response = http()(request)
    
    switch response {
    case let .success(response, _):
      if let response = response as? HTTPURLResponse {
        XCTAssertEqual(response.statusCode, 200)
      } else {
        XCTFail("Test Failure")
      }
    default:
      XCTFail("Test Failure")
    }
  }
  
  func testHTTPDownloadStream() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)
    let response = http(download: .streamContent(data: Data(), inChunksOf: 1024))(request)
    
    switch response {
    case let .success(_, download):
      switch download {
      case let .streamContent(data: _, inChunksOf: bytes):
        XCTAssertEqual(bytes, 1024)
      default:
        XCTFail("Test Failure")
      }
    case let .failure(error):
      XCTFail("Test Failure: " + (error as NSError).debugDescription)
    }
  }

  func testText() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)
    let response = text("Hello World", using: .utf8)(request)

    switch response {
    case let .success(response, download):
      switch download {
      case .content(let data):
        if let response = response as? HTTPURLResponse {
          XCTAssertEqual(response.statusCode, 200)
          XCTAssertEqual(response.mimeType, "text/plain")
          XCTAssertEqual(response.textEncodingName, "utf-8")
          let body = NSString(data:data, encoding: String.Encoding.utf8.rawValue)
          XCTAssertEqual(body, "Hello World")
        } else {
          XCTFail("Test Failure")
        }
      default:
        XCTFail("Test Failure")
      }
    default:
      XCTFail("Test Failure")
    }
  }

  func testJSON() {
    let request = URLRequest(url: URL(string: "http://test.com/")!)
    let response = json(["A"])(request)
    
    switch response {
    case let .success(response, download):
      switch download {
      case .content(let data):
        if let response = response as? HTTPURLResponse {
          XCTAssertEqual(response.statusCode, 200)
          XCTAssertEqual(response.mimeType, "application/json")
          XCTAssertEqual(response.textEncodingName, "utf-8")
          let body = NSString(data:data, encoding: String.Encoding.utf8.rawValue)
          XCTAssertEqual(body, "[\"A\"]")
        } else {
          XCTFail("Test Failure")
        }
      default:
        XCTFail("Test Failure")
      }
    default:
      XCTFail("Test Failure")
    }
  }
  
  func testJSONData() {
    let request = URLRequest(url: URL(string: "http://test.com")!)
    
    let data = "[\"B\"]".data(using: String.Encoding.utf8)!
    
    let response = jsonData(data)(request)
    
    switch response {
    case let .success(response, download):
      switch download {
      case .content(let data):
        guard let response = response as? HTTPURLResponse else {
          XCTFail("Test Failure")
          return
        }
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.mimeType, "application/json")
        XCTAssertEqual(response.textEncodingName, "utf-8")
        let body = NSString(data:data, encoding: String.Encoding.utf8.rawValue)
        XCTAssertEqual(body, "[\"B\"]")
      default:
        XCTFail("Test Failure")
      }
    default:
      XCTFail("Test Failure")
    }
  }

  func testRedirect() {
    let request = URLRequest(url: URL(string: "http://example.com")!)
    let response = redirect(to: URL(string: "https://example.com")!)(request)

    switch response {
    case let .success(response, _):
      guard let response = response as? HTTPURLResponse else {
        XCTFail("Test Failure")
        return
      }


      XCTAssertEqual(response.statusCode, 301)
      XCTAssertEqual(response.allHeaderFields["Location"] as? String, "https://example.com")
    default:
      XCTFail("Test Failure")
    }
  }

  func testRelativeRedirect() {
    let request = URLRequest(url: URL(string: "https://example.com")!)
    let response = redirect(to: URL(string: "/authorize")!)(request)

    switch response {
    case let .success(response, _):
      guard let response = response as? HTTPURLResponse else {
        XCTFail("Test Failure")
        return
      }


      XCTAssertEqual(response.statusCode, 301)
      XCTAssertEqual(response.allHeaderFields["Location"] as? String, "/authorize")
    default:
      XCTFail("Test Failure")
    }
  }
}
