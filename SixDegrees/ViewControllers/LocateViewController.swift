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

    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!

    let contactsController: SDGContactsController = SDGContactsController.sharedInstance
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager()

    var users: [SDGUser] = []
    var userIconViews: [UserIconView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.userIconView.user = SDGUser.currentUser
        self.bluetoothManager.delegate = self
    }

    override func viewDidAppear(animated: Bool) {

        self.contactsController.promptForAddressBookAccessIfNeeded { (granted) in
            if !granted {
                self.contactsController.displayCantAddContactAlert(self)
            }
        }
        // Try to get access to all the contacts of the current device
        SDGUser.currentUser.contacts = self.contactsController.contacts

        // Start advertising and browsing for devices
        self.bluetoothManager.startAdvertising()
        self.bluetoothManager.startBrowsing()
    }

    // MARK: - Functions
    func userTapped(sender: AnyObject?) {
        if let user: SDGUser = ((sender as? UITapGestureRecognizer)?.view as? UserIconView)?.user {

            let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Do you wish to connect with \(user.name)?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.bluetoothManager.invitePeer(user.peerId)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
        // Append user to the array 
        self.users.append(user)

        let userIconView: UserIconView = UserIconView(frame: CGRect(x: 40, y: 40, width: 70, height: 70))

        if let anotherUserIconView = self.userIconViews.last {
            userIconView.frame.origin.x = anotherUserIconView.frame.origin.x + 10
        }

        userIconView.iconBackgroundColor = UIColor.lightGrayColor()
        userIconView.user = user

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.userTapped(_:)))
        userIconView.addGestureRecognizer(tapGesture)

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

    /*
     Compare the contacts with on the current device with another user
     **/
    func compareContacts(withUser user: SDGUser) {
        var connections: [SDGUser] = []

        if SDGUser.currentUser.contacts != nil && user.contacts != nil {
            for userContact in user.contacts! {
                if SDGUser.currentUser.contacts!.contains(userContact) {
                    // Contacts match, add to array
                    let matchedUsername: String = "\(userContact.givenName) \(userContact.familyName)"
                    let matchedUser: SDGUser = SDGUser(peerId: MCPeerID(displayName: matchedUsername))
                    connections.append(matchedUser)
                }
            }
        }

    }
}

// MARK: - SDGBluetoothManagerDelegate
extension LocateViewController : SDGBluetoothManagerDelegate {

    func foundPeer(peer: MCPeerID) {
        let user: SDGUser = SDGUser(peerId: peer)
        self.createAndAddUser(user)
    }

    func lostPeer(peer: MCPeerID) {
        for user in self.users {
            if user.peerId == peer {
                self.removeUser(user)
            }
        }
    }

    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock: ((accept: Bool) -> Void)) {

        let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Invitation from \(peerId.displayName)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            completionBlock(accept: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) in
            completionBlock(accept: false)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func didReceiveContacts(contacts: [CNContact], fromPeer peer: MCPeerID) {
        // Get the user that has the same peerID as the peer
        let user: SDGUser? = self.users.filter { (aUser: SDGUser) -> Bool in
            return aUser.peerId == peer
        }.first

        // Assign the user contacts
        if let user = user {
            user.contacts = contacts

            // Compare contacts
            self.compareContacts(withUser: user)
        }
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        
    }

}