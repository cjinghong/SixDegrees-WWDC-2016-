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

class SDGContactsController {

    static let sharedInstance: SDGContactsController = SDGContactsController()

    let contactStore: CNContactStore = CNContactStore()

    lazy var contacts: [CNContact] = {
        let contactStore = self.contactStore
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey]

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
}
