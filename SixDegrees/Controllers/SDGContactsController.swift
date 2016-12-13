//
//  SDGAddressBookController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 07/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import PhoneNumberKit

class SDGContactsController {

    static let sharedInstance: SDGContactsController = SDGContactsController()
    let contactStore: CNContactStore = CNContactStore()

    lazy var contacts: [CNContact] = {
        let contactStore = self.contactStore
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey] as [Any]

        // Get all containers
        var containers: [CNContainer] = []
        do {
            containers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers.")
        }

        var results: [CNContact] = []

        // Loop though containers and append contacts to results
        for container in containers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults: [CNContact] = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }

        return results
    }()

    func promptForAddressBookAccessIfNeeded(_ completionBlock: @escaping ((_ granted: Bool) -> Void)) {
        let authorizationStatus: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

        switch authorizationStatus {
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted: Bool, error: NSError?) in
                completionBlock(granted)
            } as! (Bool, Error?) -> Void)
        default:
            completionBlock(true)
        }
    }

    func displayCantAddContactAlert(_ viewController: UIViewController) {
        let noAccessToContactAlert: UIAlertController = UIAlertController(title: "Cannot access contacts", message: "You need to give this app permission to access contacts for it to work properly", preferredStyle: UIAlertControllerStyle.alert)
        noAccessToContactAlert.addAction(UIAlertAction(title: "Settings", style: .default , handler: { (action: UIAlertAction) in
            let url: URL = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url)
        }))
        noAccessToContactAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
    }

    /// Returns a list of common contacts.
    func getCommonContactsWith(_ targetUserContacts: [CNContact]) -> [CNContact] {

        var matchedContacts: [CNContact] = []

        // TODO: - Important
        // Comparing contacts
        var outerLoopContacts: [CNContact] = []
        var innerLoopContacts: [CNContact] = []

        // Stores the position of the outer variable if your contacts is in the outer loop or the inner loop
        var myContactsIsOuter: Bool!

        // Use the less contacts as outper loop
        if self.contacts.count > targetUserContacts.count {
            outerLoopContacts = targetUserContacts
            innerLoopContacts = self.contacts

            myContactsIsOuter = false
        } else {
            outerLoopContacts = self.contacts
            innerLoopContacts = targetUserContacts

            myContactsIsOuter = true
        }

//        for outerContact: CNContact in outerLoopContacts {
//            let matchedContact: CNContact? = innerLoopContacts.filter({ (innerContact: CNContact) -> Bool in
//
//                for outerPhoneNumberValue in outerContact.phoneNumbers {
//                    let matchedPhoneNumber: CNLabeledValue? = innerContact.phoneNumbers.filter({ (phoneNumberValue: CNLabeledValue) -> Bool in
//                        var outerPhoneNumberString: String?
//                        var phoneNumberString: String?
//
//                        // Parse phone number
//                        do {
//                            let outerPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: (outerPhoneNumberValue.value as? CNPhoneNumber)?.stringValue ?? "")
//                            outerPhoneNumberString = outerPhoneNumber.toInternational()
//                            let phoneNumber: PhoneNumber = try PhoneNumber(rawNumber: (phoneNumberValue.value as? CNPhoneNumber)?.stringValue ?? "")
//                            phoneNumberString = phoneNumber.toInternational()
//                        } catch {
//                            // If failed to parse any contact, just strip the symbols and whitespaces
//                            outerPhoneNumberString = ((outerPhoneNumberValue.value) as? CNPhoneNumber)?.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
//                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//
//                            phoneNumberString = ((phoneNumberValue.value) as? CNPhoneNumber)?.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
//                            phoneNumberString = phoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                            phoneNumberString = phoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                        }
//
//                        if outerPhoneNumberString != nil && phoneNumberString != nil {
//                            return outerPhoneNumberString == phoneNumberString
//                        } else {
//                            return false
//                        }
//                    }).first
//
//                    if matchedPhoneNumber != nil {
//                        return true
//                    }
//                }
//                return false
//            }).first
//
//            if matchedContact != nil {
//                matchedContacts.append(matchedContact!)
//            }
//        }


        var outerLoopCount: Int = 0
        for outerContact: CNContact in outerLoopContacts {
            print("Outer Loop: \(outerLoopCount)")
            outerLoopCount += 1
            var innerLoopCount: Int = 0
            innerContactsLoop: for innerContact: CNContact in innerLoopContacts {

                print("Inner Loop \(innerLoopCount)")
                innerLoopCount += 1
                // Comparing phone numbers
                for outerContactPhoneNumberLV: CNLabeledValue in outerContact.phoneNumbers {
                    for innerContactPhoneNumberLV: CNLabeledValue in innerContact.phoneNumbers {

                        let outerContactPhoneNumberValue: String? = (outerContactPhoneNumberLV.value as? CNPhoneNumber)?.stringValue
                        let innerContactPhoneNumberValue: String? = (innerContactPhoneNumberLV.value as? CNPhoneNumber)?.stringValue

                        var outerPhoneNumberString: String?
                        var innerPhoneNumberString: String?

                        do {
                            let outerPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: outerContactPhoneNumberValue ?? "")
                            outerPhoneNumberString = outerPhoneNumber.toInternational()
                            let innerPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: innerContactPhoneNumberValue ?? "")
                            innerPhoneNumberString = innerPhoneNumber.toInternational()
                        } catch {
                            // If failed to parse any contact, just strip the symbols and whitespaces
                            outerPhoneNumberString = outerContactPhoneNumberValue?.trimmingCharacters(in: CharacterSet.symbols)
                            outerPhoneNumberString = outerPhoneNumberString?.replacingOccurrences(of: " ", with: "")
                            outerPhoneNumberString = outerPhoneNumberString?.replacingOccurrences(of: " ", with: "")

                            innerPhoneNumberString = innerContactPhoneNumberValue?.trimmingCharacters(in: CharacterSet.symbols)
                            innerPhoneNumberString = innerPhoneNumberString?.replacingOccurrences(of: " ", with: "")
                            innerPhoneNumberString = innerPhoneNumberString?.replacingOccurrences(of: " ", with: "")
                        }

                        if outerPhoneNumberString != nil && innerPhoneNumberString != nil {
                            if outerPhoneNumberString == innerPhoneNumberString {
                                if myContactsIsOuter == true {
                                    matchedContacts.append(outerContact)
                                } else {
                                    matchedContacts.append(innerContact)
                                }
                                // Break from looping the inner contacts loop once the same contact with outer contacts is found.
                                break innerContactsLoop
                            }
                        }
                    }
                }

                for myEmail: CNLabeledValue in outerContact.emailAddresses {
                    for userEmail: CNLabeledValue in innerContact.emailAddresses {
                        if (myEmail.value as? String) == (userEmail.value as? String) {
                            if myContactsIsOuter == true {
                                matchedContacts.append(outerContact)
                            } else {
                                matchedContacts.append(innerContact)
                            }
                            break innerContactsLoop
                        }
                    }
                }

            }
        }

        return matchedContacts
    }

}
