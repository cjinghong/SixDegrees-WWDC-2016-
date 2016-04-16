//
//  CNContact+JH.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 09/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit

extension CNContact {
    /// Compare self with another CNContact. Returns true if they are the same.
    /// - Parameter contact: The CNContact to compare with
    /// - Returns: matched: Boolean value. True if both contacts are the same, false if not. identifier: If phone number matches, the identifier will be the phone number. If the email matches, the identifier will be the email
    func compareAndGetIdentifier(contact: CNContact) -> (matched: Bool, identifier: String?) {
        // Compare phone numbers
        if self.isKeyAvailable(CNContactPhoneNumbersKey) && contact.isKeyAvailable(CNContactPhoneNumbersKey) {

            for myPhoneNumberCN: CNLabeledValue in self.phoneNumbers {
                for userPhoneNumberCN: CNLabeledValue in contact.phoneNumbers {

                    if myPhoneNumberCN.valueForKey("digits") != nil && userPhoneNumberCN.valueForKey("digits") != nil {
                        do {
                            let myPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: myPhoneNumberCN.valueForKey("digits") as! String)
                            let userPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: userPhoneNumberCN.valueForKey("digits") as! String)

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

//                    // Tries to remove country code from the numbers (If applicable)
//                    var myPhoneNumberFormatted: String = (myPhoneNumber.value as! CNPhoneNumber).valueForKey("formattedStringValue") as! String
//                    if myPhoneNumberFormatted.containsString("+") {
//                        if let spaceIndex = myPhoneNumberFormatted.rangeOfString(" ")?.startIndex {
//                            let index: Int = myPhoneNumberFormatted.startIndex.distanceTo(spaceIndex)
//                            myPhoneNumberFormatted = myPhoneNumberFormatted.substringWithRange(myPhoneNumberFormatted.startIndex.advancedBy(index+1)..<myPhoneNumberFormatted.endIndex)
//                        }
//                    }
//                    var userPhoneNumberFormatted: String = (userPhoneNumber.value as! CNPhoneNumber).valueForKey("formattedStringValue") as! String
//                    if userPhoneNumberFormatted.containsString("+") {
//                        if let spaceIndex = userPhoneNumberFormatted.rangeOfString(" ")?.startIndex {
//                            let index: Int = userPhoneNumberFormatted.startIndex.distanceTo(spaceIndex)
//                            userPhoneNumberFormatted = userPhoneNumberFormatted.substringWithRange(userPhoneNumberFormatted.startIndex.advancedBy(index+1)..<userPhoneNumberFormatted.endIndex)
//                        }
//                    }
//
//                    // Strips off the spaces
//                    myPhoneNumberFormatted = myPhoneNumberFormatted.stringByReplacingOccurrencesOfString(" ", withString: "")
//                    userPhoneNumberFormatted = userPhoneNumberFormatted.stringByReplacingOccurrencesOfString(" ", withString: "")
//
//                    // Removes the first 0 if applicable
//                    if myPhoneNumberFormatted[myPhoneNumberFormatted.startIndex] == "0" {
//                        myPhoneNumberFormatted.removeAtIndex(myPhoneNumberFormatted.startIndex)
//                    }
//                    if userPhoneNumberFormatted[userPhoneNumberFormatted.startIndex] == "0" {
//                        userPhoneNumberFormatted.removeAtIndex(userPhoneNumberFormatted.startIndex)
//                    }
//
//                    if myPhoneNumberFormatted == userPhoneNumberFormatted {
//                        return (true, myPhoneNumberFormatted)
//                    }

                }
            }
        }
        // Compare email address
        if self.isKeyAvailable(CNContactEmailAddressesKey) && contact.isKeyAvailable(CNContactEmailAddressesKey) {
            for myEmail: CNLabeledValue in self.emailAddresses {
                for userEmail: CNLabeledValue in contact.emailAddresses {
                    if (myEmail.value as? String) == (userEmail.value as? String) {
                        return (true, (myEmail.value as! String))
                    }
                }
            }
        }
        return (false, nil)
    }
}


