////
////  SixDegreesTests.swift
////  SixDegreesTests
////
////  Created by Chan Jing Hong on 28/03/2016.
////  Copyright © 2016 Chan Jing Hong. All rights reserved.
////
//
//import XCTest
////import SDGRestAPI
//@testable import SixDegrees
//
//class SixDegreesTests: XCTestCase {
//    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//    func testGetUser() {
//
//        let expectation = self.expectationWithDescription("Get user")
//
//        let tokenString: String = "CAACEdEose0cBAGFCfPNUDJg74X6Gv6IPfmhNlNX0LGmoHJX3l1PyJYfeuMZBZB1uYrGZAg9oSpXX34AGbiZATaMjTPp5cVElsMXhkCoqZC1MBXSKaAuWyDDSf2pwKH5jDfQO1kluS2RdPNebLDhf11jASeyXXTTPzaVAaVktqWGAZBFFK45qAuxqem0MZCTFn6kVZBl3pYTXHvicny9CmhphZAsSS7GAQS0YZD"
//        let path: String = "https://graph.facebook.com/v2.5/10204547778911189"
//
//        var params: [String : AnyObject] = [:]
//        params["fields"] = "id,name,gender,picture"
//
//        if let tokenString = self.accessTokenString {
//            params["access_token"] = tokenString
//        }
//
//        SDGRestAPI.request(method: .GET, path: path, parameters: params, contentType: .JSON, encoding: .URL, additionalHeaders: [:]).responseJSON { (response: Response<AnyObject, NSError>) in
//
//            var user: SDGUser?
//
//            if let value = response.result.value {
//                let json: JSON = JSON(value)
//
//                if let user: SDGUser = SDGUser(json: json) {
//                    user = user
//                }
//            }
//
//            XCTAssert(user != nil, "User should not be nil")
//            expectation.fulfill()
//        }
//        self.waitForExpectationsWithTimeout(10, handler: nil)
//        
//    }
//}
