//
//  CNContact+JH.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 09/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import Contacts

extension CNContact {
    func compare(contact: CNContact) {

    }
}

public func == (lhs: CNContact, rhs: CNContact) -> Bool {
    // Compare phone numbers
    if lhs.isKeyAvailable(CNContactPhoneNumbersKey) && rhs.isKeyAvailable(CNContactPhoneNumbersKey) {
        for phoneNumber: CNLabeledValue in lhs.phoneNumbers {
            if rhs.phoneNumbers.contains(phoneNumber) {
                return true
            }
        }
    }
    // Compare email address
    if lhs.isKeyAvailable(CNContactEmailAddressesKey) && rhs.isKeyAvailable(CNContactEmailAddressesKey) {
        for email: CNLabeledValue in lhs.emailAddresses {
            if rhs.emailAddresses.contains(email) {
                return true
            }
        }
    }
    return false
}

