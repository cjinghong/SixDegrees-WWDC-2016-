//
//  SDGAPITests.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 02/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import SixDegrees

class SDGAPITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

    func testGetUser() {
        let expectation = self.expectationWithDescription("Test get user")

        SDGRestAPI.sharedClient.getUser(withUserID: "10204547778911189") { (user, error) in
            XCTAssert(user != nil, "User should not be nil")
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
