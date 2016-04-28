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

    func compareContactsWith(targetUserContacts: [CNContact]) -> [CNContact] {

        var matchedContacts: [CNContact] = []

        // TODO: - Important
        // Comparing contacts
        for myContact: CNContact in self.contacts {
            targetContactsLoop: for targetContact: CNContact in targetUserContacts {

                // Comparing phone numbers
                for myPhoneNumberCN: CNLabeledValue in myContact.phoneNumbers {
                    for userPhoneNumberCN: CNLabeledValue in targetContact.phoneNumbers {

                        let myPhoneNumberValue: String? = (myPhoneNumberCN.value as? CNPhoneNumber)?.stringValue
                        let userPhoneNumberValue: String? = (userPhoneNumberCN.value as? CNPhoneNumber)?.stringValue

                        var myPhoneNumberString: String?
                        var userPhoneNumberString: String?

                        do {
                            let myPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: myPhoneNumberValue ?? "")
                            myPhoneNumberString = myPhoneNumber.toInternational()
                            let userPhoneNumber: PhoneNumber = try PhoneNumber(rawNumber: userPhoneNumberValue ?? "")
                            userPhoneNumberString = userPhoneNumber.toInternational()
                        } catch {
                            // If failed to parse any contact, just strip the symbols and whitespaces
                            myPhoneNumberString = myPhoneNumberValue?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                            myPhoneNumberString = myPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
                            myPhoneNumberString = myPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")

                            userPhoneNumberString = userPhoneNumberValue?.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                            userPhoneNumberString = userPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
                            userPhoneNumberString = userPhoneNumberString?.stringByReplacingOccurrencesOfString(" ", withString: "")
                        }

                        if myPhoneNumberString != nil && userPhoneNumberString != nil {
                            if myPhoneNumberString == userPhoneNumberString {
                                matchedContacts.append(myContact)
                                // Break from looping the target contacts loop once the same contact with MyContact is found.
                                break targetContactsLoop
                            }
                        }
                    }
                }

                for myEmail: CNLabeledValue in myContact.emailAddresses {
                    for userEmail: CNLabeledValue in targetContact.emailAddresses {
                        if (myEmail.value as? String) == (userEmail.value as? String) {
                            matchedContacts.append(myContact)
                            break targetContactsLoop
                        }
                    }
                }

            }
        }

        return matchedContacts
    }




}
