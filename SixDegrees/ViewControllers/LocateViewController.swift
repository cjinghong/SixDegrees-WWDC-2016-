//
//  ViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import FBSDKLoginKit

import Contacts
import MultipeerConnectivity

class LocateViewController: UIViewController {

    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!
    var originalUserIconHorizontalConstraint: CGFloat?
    @IBOutlet weak var findConnectionsButton: UIButton!
    @IBOutlet weak var findConnectionsBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var discoveredUsersCollectionView: UICollectionView!

    let contactsController: SDGContactsController = SDGContactsController.sharedInstance
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager()

    var discoveredUsers: [SDGUser] = []
    var userIconViews: [UserIconView] = []
    var originalChosenUserIconFrame: CGRect?

    // Collectionview animation variables
    var userOriginalIndexPath: NSIndexPath?
    var userCurrentIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.SDGLightBlue()

        self.userIconView.user = SDGUser.currentUser
        self.bluetoothManager.delegate = self

        // Start advertising and browsing for devices
        self.bluetoothManager.startAdvertising()
        self.bluetoothManager.startBrowsing()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.sharedApplication())

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
//    func userTapped(sender: AnyObject?) {
//        if let user: SDGUser = ((sender as? UITapGestureRecognizer)?.view as? UserIconView)?.user {
//
//            let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Do you wish to connect with \(user.name)?", preferredStyle: UIAlertControllerStyle.Alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
//                self.bluetoothManager.invitePeer(user.peerId)
//            }))
//            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
//
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
//    }

    @IBAction func findConnections(sender: AnyObject) {
        if let contacts = SDGUser.currentUser.contacts {
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: contacts)
            }
        }
    }

//    func animateUserToOriginalPosition(user: SDGUser?) {
//        if let user = user {
//            let index: Int? = self.discoveredUsers.indexOf(user)
//            if let index: Int = index {
//                if let frame = self.originalChosenUserIconFrame {
//                    UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
//                    self.userIconViews[index].frame = frame
//                    self.view.layoutIfNeeded()
//                    }, completion: nil)
//                }
//            }
//        }
//        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
//            self.userIconHorizontalConstraint.constant = self.originalUserIconHorizontalConstraint ?? 0
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }

//    func animateConnectingToUser(user: SDGUser?) {
//        if let user = user {
//            // Find the respective user icon view
//            let index: Int? = self.discoveredUsers.indexOf(user)
//            if let index = index {
//                let chosenUserIcon: UserIconView = self.userIconViews[index]
//
//                // Remove all users except for that user icon view
//                for userIconView in self.userIconViews {
//                    if userIconView != chosenUserIcon {
//                        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
//                            userIconView.alpha = 0
//                            }, completion: { (success: Bool) in
//                                userIconView.removeFromSuperview()
//                        })
//                    }
//                }
//                // Store reference of the chosen user icon's frame
//                self.originalChosenUserIconFrame = chosenUserIcon.frame
//                let chosenIconDistanceFromTop: CGFloat = chosenUserIcon.frame.origin.y
//                let userIconDistanceFromBottom: CGFloat = self.view.frame.height - self.userIconView.frame.origin.y - self.userIconView.frame.height - 28 // 28 is the height of the name label
//
//                // Find out what should the distance of the icons should be
//                let equalDistance: CGFloat = (userIconDistanceFromBottom + chosenIconDistanceFromTop) / 2
//
//                if chosenUserIcon.frame.origin.y != equalDistance && self.userIconHorizontalConstraint.constant == 0 {
//                    UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//                        // Center user icons
//                        chosenUserIcon.frame.origin.x = self.userIconView.frame.origin.x
//                        self.userIconHorizontalConstraint.constant = equalDistance - 20
//                        chosenUserIcon.frame.origin.y = equalDistance
//
//                        self.view.layoutIfNeeded()
//                        }, completion: nil)
//                }
//            }
//        }
//    }

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
                        let matchedUser: SDGUser = SDGUser(peerId: MCPeerID(displayName: matchedUsername), color: UIColor.randomSDGColor())
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
        let user: SDGUser = SDGUser(peerId: peer, color: UIColor.randomSDGColor())
        if !self.discoveredUsers.contains(user) {
            self.discoveredUsers.append(user)
            self.discoveredUsersCollectionView.reloadData()
        }
    }

    func lostPeer(peer: MCPeerID) {
        for user in self.discoveredUsers {
            if user.peerId == peer {
                // Animation should be pushed to the main queue
                dispatch_async(dispatch_get_main_queue(), {
//                    self.animateUserToOriginalPosition(user)
                    self.discoveredUsersCollectionView.reloadData()
                })
            }
        }
    }

    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock: ((accept: Bool) -> Void)) {

        // Automatically accepts all connections IF self current device is a simulator for testing purpose
        if SDGUser.currentUser.name == "iPhone Simulator" {
            completionBlock(accept: true)
            return
        }

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
        let user: SDGUser? = self.discoveredUsers.filter { (aUser: SDGUser) -> Bool in
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
            let user: SDGUser? = self.discoveredUsers.filter({ (user: SDGUser) -> Bool in
                user.peerId == peerId
            }).first
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), {
                // TODO: Animate connecting to user
//                self.animateConnectingToUser(user)
            })
        } else {
            // Animation should be pushed to the main queue
            let user: SDGUser? = self.discoveredUsers.filter({ (user: SDGUser) -> Bool in
                user.peerId == peerId
            }).first
            dispatch_async(dispatch_get_main_queue(), {
                self.hideConnectButton()
//                self.animateUserToOriginalPosition(user)

                // TODO: Move cell from the index path back to its original position
                if self.userCurrentIndexPath != nil && self.userOriginalIndexPath != nil {
                    self.discoveredUsersCollectionView.moveItemAtIndexPath(self.userCurrentIndexPath!, toIndexPath: self.userOriginalIndexPath!)
                    self.userCurrentIndexPath = nil
                    self.userOriginalIndexPath = nil
                }
            })
        }

    }
}

// MARK: - CollectionView Datasource and Delegate
extension LocateViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func indexPathForClosestCell() -> NSIndexPath? {
        let screenCenterX: CGFloat = self.view.center.x
        let bottomOfCollectionView: CGFloat = self.discoveredUsersCollectionView.frame.origin.x + self.discoveredUsersCollectionView.frame.size.height - 8 // Give extra 8 pixels so it wouldnt go outside of the collecitonview

        let closestPointInView: CGPoint = CGPoint(x: screenCenterX, y: bottomOfCollectionView)
        let closestPointInCollectionView: CGPoint = self.view.convertPoint(closestPointInView, toView: self.discoveredUsersCollectionView)

        return self.discoveredUsersCollectionView.indexPathForItemAtPoint(closestPointInCollectionView)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Collection view will have at least enough cell to fill up the rows
        return self.discoveredUsers.count
//        return 20
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell

        // Reset cell
        cell.hidden = false

        // Testing purpose
//        if !self.discoveredUsers.isEmpty {
//            cell.user = self.discoveredUsers[0]
//        } else {
//            cell.user = nil
//        }
        if indexPath.row < self.discoveredUsers.count {
            cell.user = self.discoveredUsers[indexPath.row]
        } else {
            // Hide cells if not enough user to fill it up.
            cell.hidden = true
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // Animate cell appearing
        cell.alpha = 0
        cell.transform = CGAffineTransformMakeScale(0.5, 0.5)

        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            cell.transform = CGAffineTransformIdentity
            cell.alpha = 1
        }) { (success: Bool) in
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        // TODO: Take snippet, transition to another screen
        let connectionsVC: ConnectionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ConnectionsViewController") as! ConnectionsViewController
        connectionsVC.connectingUser = self.discoveredUsers[indexPath.row]
        self.navigationController?.pushViewController(connectionsVC, animated: true)
    }


}





