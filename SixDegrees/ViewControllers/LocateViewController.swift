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
    var originalUserIconHorizontalConstraint: CGFloat?
    @IBOutlet weak var findConnectionsButton: UIButton!
    @IBOutlet weak var findConnectionsBottomConstraint: NSLayoutConstraint!

    let contactsController: SDGContactsController = SDGContactsController.sharedInstance
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager()

    var users: [SDGUser] = []
    var userIconViews: [UserIconView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.userIconView.user = SDGUser.currentUser
        self.bluetoothManager.delegate = self

        // Start advertising and browsing for devices
        self.bluetoothManager.startAdvertising()
        self.bluetoothManager.startBrowsing()
    }

    override func viewWillAppear(animated: Bool) {
        // Store reference of the userIconHorizontalConstraint
        self.originalUserIconHorizontalConstraint = self.userIconHorizontalConstraint.constant

        if self.bluetoothManager.session.connectedPeers.count > 0 {
            self.showConnectButton()
        } else {
            self.hideConnectButton()
        }
    }

    override func viewDidAppear(animated: Bool) {

        self.contactsController.promptForAddressBookAccessIfNeeded { (granted) in
            if !granted {
                self.contactsController.displayCantAddContactAlert(self)
            }
        }
        // Try to get access to all the contacts of the current device
        SDGUser.currentUser.contacts = self.contactsController.contacts
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

    @IBAction func findConnections(sender: AnyObject) {
        if let contacts = SDGUser.currentUser.contacts {
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: contacts)
            }
        }
    }

    func createAndAddUser(user: SDGUser) {
        // Append user to the array
        self.users.append(user)

        let userIconView: UserIconView!

        if let anotherUserIconView = self.userIconViews.last {
            userIconView = UserIconView(frame: CGRect(x: anotherUserIconView.frame.origin.x + 70 + 38, y: 40, width: 70, height: 70))
        } else {
            userIconView = UserIconView(frame: CGRect(x: 40, y: 40, width: 70, height: 70))
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

    func animateUserToOriginalPosition() {
        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.userIconHorizontalConstraint.constant = 0
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func animateConnectingToUser(user: SDGUser?) {
        if let user = user {
            // Find the respective user icon view
            let index: Int? = self.users.indexOf(user)
            if let index = index {
                let chosenUserIcon: UserIconView = self.userIconViews[index]

                // Remove all users except for that user icon view
                for userIconView in self.userIconViews {
                    if userIconView != chosenUserIcon {
                        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                            userIconView.alpha = 0
                            }, completion: { (success: Bool) in
                                userIconView.removeFromSuperview()
                        })
                    }
                }
                let chosenIconDistanceFromTop: CGFloat = chosenUserIcon.frame.origin.y
                let userIconDistanceFromBottom: CGFloat = self.view.frame.height - self.userIconView.frame.origin.y - self.userIconView.frame.height - 28 // 28 is the height of the name label

                // Find out what should the distance of the icons should be
                let equalDistance: CGFloat = (userIconDistanceFromBottom + chosenIconDistanceFromTop) / 2

                if chosenUserIcon.frame.origin.y != equalDistance && self.userIconHorizontalConstraint.constant == 0 {
                    UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        // Center user icons
                        chosenUserIcon.frame.origin.x = self.userIconView.frame.origin.x
                        self.userIconHorizontalConstraint.constant = equalDistance - 20
                        chosenUserIcon.frame.origin.y = equalDistance

                        self.view.layoutIfNeeded()
                        }, completion: nil)
                }
            }
        }
    }

    func showConnectButton() {
        // Check if button is already hidden
        if self.findConnectionsBottomConstraint.constant < 8 {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.findConnectionsBottomConstraint.constant = 8
                self.findConnectionsButton.alpha = 1
            }) { (success: Bool) in
            }
        }
    }

    func hideConnectButton() {
        // Check if button is already hidden
        if self.findConnectionsBottomConstraint.constant == 8 {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.findConnectionsBottomConstraint.constant = -38
                self.findConnectionsButton.alpha = 0
            }) { (success: Bool) in
            }
        }
    }

    /*
     Compare the contacts with on the current device with another user
     **/
    func compareContacts(withUser user: SDGUser) -> [SDGUser] {
        var connections: [SDGUser] = []

        if SDGUser.currentUser.contacts != nil && user.contacts != nil {
            for myContact: CNContact in SDGUser.currentUser.contacts! {
                for userContact: CNContact in user.contacts! {
                    let results: (matched: Bool, identifier: String?) = myContact.compareAndGetIdentifier(userContact)

                    if results.matched {
                        let matchedUsername: String = "\(myContact.givenName) \(myContact.familyName)"
                        let matchedUser: SDGUser = SDGUser(peerId: MCPeerID(displayName: matchedUsername))
                        matchedUser.identifierString = results.identifier

                        // Only appends if it is not a repeating user contact
                        if !connections.contains({ (aUser: SDGUser) -> Bool in
                            return aUser.identifierString == matchedUser.identifierString
                        }) {
                            connections.append(matchedUser)
                        }
                    }
                }
            }
        }
        return connections
    }
}

// MARK: - SDGBluetoothManagerDelegate
extension LocateViewController : SDGBluetoothManagerDelegate {

    func foundPeer(peer: MCPeerID) {
        let user: SDGUser = SDGUser(peerId: peer)
        if !self.users.contains(user) {
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), { 
                self.createAndAddUser(user)
            })
        }
    }

    func lostPeer(peer: MCPeerID) {
        for user in self.users {
            if user.peerId == peer {
                // Animation should be pushed to the main queue
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeUser(user)
                    self.animateUserToOriginalPosition()
                })
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
            let connections: [SDGUser] = self.compareContacts(withUser: user)
            // TODO: Draw connections
        }
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        if state == .Connected {
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), {
                self.showConnectButton()
            })
        } else if state == .Connecting {
            let user: SDGUser? = self.users.filter({ (user: SDGUser) -> Bool in
                user.peerId == peerId
            }).first
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), {
                self.animateConnectingToUser(user)
            })
        } else {
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), {
                self.hideConnectButton()
                self.animateUserToOriginalPosition()
            })
        }

    }

}