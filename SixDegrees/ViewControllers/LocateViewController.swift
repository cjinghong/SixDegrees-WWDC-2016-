//
//  ViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKCoreKit

import Contacts
import MultipeerConnectivity

class LocateViewController: UIViewController {

    @IBOutlet weak var userIconEncapsulatingView: UIView!
    @IBOutlet weak var userIconView: UserIconView!

    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!

    let contactsController: SDGContactsController = SDGContactsController.sharedInstance
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager()

    var users: [SDGUser] = []
    var userIconViews: [UserIconView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.userIconView.user = SDGUser(peerId: MCPeerID(displayName: UIDevice.currentDevice().name))
    }

    override func viewDidAppear(animated: Bool) {

        self.contactsController.promptForAddressBookAccessIfNeeded { (granted) in
            if !granted {
                self.contactsController.displayCantAddContactAlert(self)
            }
        }
        self.bluetoothManager.delegate = self

        self.bluetoothManager.startAdvertising()
        self.bluetoothManager.startBrowsing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userTapped(sender: AnyObject?) {
        showSimpleAlert("Alert", message: "Yo")
    }

    // Slowly moves the icon slightly upwards and downwards indefinately
    func bounceUserIcon(upwardsDirection: Bool = true) {
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {

            if upwardsDirection {
                self.userIconHorizontalConstraint.constant += 10
            } else {
                self.userIconHorizontalConstraint.constant -= 10
            }
            self.view.layoutIfNeeded()

        }) { (completed: Bool) in
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    if upwardsDirection {
                        self.userIconHorizontalConstraint.constant -= 10
                    } else {
                        self.userIconHorizontalConstraint.constant += 10
                    }
                    self.view.layoutIfNeeded()

                    }, completion: { (completed: Bool) in
                        self.bounceUserIcon(!upwardsDirection)
                })
        }
    }

    func createAndAddUser(user: SDGUser) {
        let userIconView: UserIconView = UserIconView(frame: CGRect(x: 40, y: 40, width: 70, height: 70))
        userIconView.iconBackgroundColor = UIColor.lightGrayColor()
        userIconView.user = user
        userIconView.alpha = 0

        self.userIconViews.append(userIconView)
        self.view.addSubview(userIconView)

        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { 
            userIconView.alpha = 1
            }, completion: nil)
    }

    func removeUser(user: SDGUser) {
        if let userIndex = self.users.indexOf(user) {
            // Remove user icon view
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.userIconViews[userIndex].alpha = 0
                }, completion: { (completed: Bool) in
                    self.userIconViews[userIndex].removeFromSuperview()
                    self.userIconViews.removeAtIndex(userIndex)

                    self.users.removeAtIndex(userIndex)
            })
        }
    }
}

extension LocateViewController : SDGBluetoothManagerDelegate {

    func didUpdatePeers(peers: [MCPeerID]) {
        if self.users.isEmpty {
            for peer in peers {
                let user: SDGUser = SDGUser(peerId: peer)
                self.users.append(user)
                self.createAndAddUser(user)
            }
        } else {
            // Compare the missing peers and make it disspear
            for user: SDGUser in self.users {
                // If the results doesn't contain that user, remove it
                if !(peers.contains(user.peerId)) {
                    self.removeUser(user)
                }
            }
        }

    }

    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock: ((accept: Bool) -> Void)) {

        let alertController: UIAlertController = UIAlertController(title: "Invitation", message: "Invitation from \(peerId.displayName)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            completionBlock(accept: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func connectedDeviceChanged(manager: SDGBluetoothManager, connectedDevices: [String]) {
        
    }

    func didReceiveContacts(contacts: [CNContact], fromPeer peer: MCPeerID) {
        let user: SDGUser? = self.users.filter { (aUser: SDGUser) -> Bool in
            return aUser.peerId == peer
        }.first

        if let user = user {
            user.contacts = contacts
        }
    }

}

// MARK: - Utils
extension UIViewController {

    func showSimpleAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}


