//
//  SDGTests.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 23/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import XCTest
import PhoneNumberKit
import CoreData

@testable import SixDegrees

class SDGTests: XCTestCase {

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

    func testComparingContacts() {
        do {
            // TODO: Figure out why unable to go through try block
            let myPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: "")
            let userPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: "")

            let myPhoneNumberString: String = myPhoneNumber.toInternational()
            let userPhoneNumberString: String = userPhoneNumber.toInternational()

            if myPhoneNumberString == userPhoneNumberString {
                return (true, myPhoneNumberString)
            }
        } catch {
            print("Generic Parser error")
            return (false, nil)
        }
    }

    func testFetchingFromCoreData() {
        let MOC: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SDGConnection")

        do {
            let connections: [SDGConnection] = try MOC.executeFetchRequest(fetchRequest) as! [SDGConnection]
        } catch {
            print("error")
        }


    }
}
