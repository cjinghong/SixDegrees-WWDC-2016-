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
            CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey]

        // Get all containers
        var containers: [CNContainer] = []
        do {
            containers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers.")
        }

        var results: [CNContact] = []

        // Loop though containers and append contacts to results
        for container in containers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            do {
                let containerResults: [CNContact] = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }

        return results
    }()

    func promptForAddressBookAccessIfNeeded(completionBlock: ((granted: Bool) -> Void)) {
        let authorizationStatus: CNAuthorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)

        switch authorizationStatus {
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (granted: Bool, error: NSError?) in
                completionBlock(granted: granted)
            })
        default:
            completionBlock(granted: true)
        }
    }

    func displayCantAddContactAlert(viewController: UIViewController) {
        let noAccessToContactAlert: UIAlertController = UIAlertController(title: "Cannot access contacts", message: "You need to give this app permission to access contacts for it to work properly", preferredStyle: UIAlertControllerStyle.Alert)
        noAccessToContactAlert.addAction(UIAlertAction(title: "Settings", style: .Default , handler: { (action: UIAlertAction) in
            let url: NSURL = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }))
        noAccessToContactAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    }

    /// Returns a list of common contacts.
    func getCommonContactsWith(targetUserContacts: [CNContact]) -> [CNContact] {

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

        for outerContact: CNContact in outerLoopContacts {
//
//            let matchedContact: CNContact? = innerLoopContacts.filter({ (innerContact: CNContact) -> Bool in
//                var phoneNumberMatches: Bool = false
//
//                for outerLabeledValue in outerContact.phoneNumbers {
//                    let matchedPhoneNumber: CNLabeledValue? = innerContact.phoneNumbers.filter({ (innerLabeledValue: CNLabeledValue) -> Bool in
//
//                        var outerPhoneNumberString: String?
//                        var innerPhoneNumberString: String?
//
//                        // Parse phone number
//                        do {
//                            let outerPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: (outerLabeledValue.value as? String) ?? "")
//                            outerPhoneNumberString = outerPhoneNumber.toInternational()
//                            let innerPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: (innerLabeledValue.value as? String) ?? "")
//                            innerPhoneNumberString = innerPhoneNumber.toInternational()
//                        } catch {
//                            // If failed to parse any contact, just strip the symbols and whitespaces
//                            outerPhoneNumberString = (outerLabeledValue.value as? String)?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
//                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//
//                            innerPhoneNumberString = (innerLabeledValue.value as? String)?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
//                            innerPhoneNumberString = innerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                            innerPhoneNumberString = innerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
//                        }
//                        return outerPhoneNumberString == innerPhoneNumberString
//                    }).first
//
//                    // Store a bool whether there is a matched phone number
//                    if matchedPhoneNumber != nil {
//                        phoneNumberMatches = true
//                        break
//                    } else {
//                        phoneNumberMatches = false
//                    }
//                }
//                return phoneNumberMatches
//            }).first
//
//            if matchedContact != nil {
//                matchedContacts.append(matchedContact!)
//            }
//        }
//
//        return matchedContacts
//    }

            innerContactsLoop: for innerContact: CNContact in innerLoopContacts {

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
                            outerPhoneNumberString = outerContactPhoneNumberValue?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
                            outerPhoneNumberString = outerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")

                            innerPhoneNumberString = innerContactPhoneNumberValue?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                            innerPhoneNumberString = innerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
                            innerPhoneNumberString = innerPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
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
