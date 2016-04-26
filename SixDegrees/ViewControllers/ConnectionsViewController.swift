//
//  ConnectionsViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 20/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import Contacts
import MultipeerConnectivity
import MBProgressHUD
import CoreData

class ConnectionsViewController: UIViewController {

    @IBOutlet weak var connectingUserIconView: UserIconView!
    @IBOutlet weak var connectingUserHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var mutualUsersCollectionView: UICollectionView!

    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!

    @IBOutlet weak var disconnectButton: UIButton!

    var connectingUser: SDGUser!
    var mutualUsers: [SDGUser] = []

    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager.sharedInstance
    var hud: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userIconView.user = SDGUser.currentUser
        self.connectingUserIconView.user = self.connectingUser

        // Changes the delegate to self
        self.bluetoothManager.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.sharedApplication())
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Send contacts
        if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
            SDGContactsController.sharedInstance.promptForAddressBookAccessIfNeeded { (granted) in
                if !granted {
                    SDGContactsController.sharedInstance.displayCantAddContactAlert(self)
                } else {
                    self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: SDGUser.currentUser.contacts ?? [])

                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    self.hud?.labelText = "Finding connections...\nThis may take awhile"
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Compare the contacts with on the current device with another user
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

    func createAndAddUser(user: SDGUser) {
        // Append user to the array
        let userIconView: UserIconView!
        userIconView = UserIconView(frame: CGRect(x: self.view.center.x - 35, y: self.view.center.y - 35, width: 70, height: 70))

        userIconView.iconBackgroundColor = UIColor.lightGrayColor()
        userIconView.user = user

        userIconView.alpha = 0

        self.view.addSubview(userIconView)

        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            userIconView.alpha = 1
            }, completion: nil)
    }

    @IBAction func disconnect(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "Disconnect", message: "Are you sure you want to disconnect from the current session?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            // Disconnect self, then pop back to vc.
            self.bluetoothManager.session.disconnect()
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) in
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

extension ConnectionsViewController: SDGBluetoothManagerDelegate {

    func foundPeer(peer: MCPeerID) {
        return
    }

    func lostPeer(peer: MCPeerID) {
        // If the lost peer is the connecting user, disconnect
        if peer == self.connectingUser.peerId {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)
                
                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "You have disconnected from \(peer.displayName). Please do not turn off the wifi of both the devices.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                    // Disconnect self, then pop back to vc.
                    self.bluetoothManager.session.disconnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }

    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock:((accept: Bool)->Void)) {
        // Automatically reject invitation if aleady in a session
        completionBlock(accept: false)
    }

    func didReceiveContacts(contacts: [CNContact], fromPeer peer: MCPeerID) {
        self.connectingUser.contacts = contacts

        // Compare contacts, and populate array
        let mutualUsers: [SDGUser] = self.compareContacts(withUser: self.connectingUser)
        self.mutualUsers = mutualUsers
        self.mutualUsersCollectionView.reloadData()

        // Save connection to Core Data
        let MOC: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let connection: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
        connection.date = NSDate()
        connection.myUserName = SDGUser.currentUser.name
        connection.targetUserName = self.connectingUser.name
        
        var usernames: [String] = []
        for user: SDGUser in mutualUsers {
            usernames.append(user.name)
        }
        connection.mutualUserNames = usernames
        do {
            try MOC.save()
        } catch {
            print("Error trying to save to Core Data. \(error)")
        }


        // TODO: Draw connections with collection view to be able to see multiple connections
        if !mutualUsers.isEmpty {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)

                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.connectingUserHorizontalConstraint.constant -= 75
                    self.userIconHorizontalConstraint.constant += 75

                    let connection: SDGUser = SDGUser(peerId: mutualUsers.first!.peerId, color: UIColor.randomSDGColor())
                    self.createAndAddUser(connection)

                    self.view.layoutIfNeeded()
                    }, completion: nil)
            })
        }
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        // If state is not connected, pop back to previous vc

        if state != .Connected {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)

                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "You have disconnected from \(peerId.displayName). Please do not turn off the wifi of both the devices.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                    // Disconnect self, then pop back to vc.
                    self.bluetoothManager.session.disconnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
}

extension ConnectionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mutualUsers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell
        cell.user = self.mutualUsers[indexPath.row]
        return cell
    }

}


