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

    var displayMode: SDGDisplayMode! {
        didSet {
            if displayMode == SDGDisplayMode.Simulated {
                self.simulationReminderTopConstraint.constant = 0
                self.simulationReminderView.hidden = false

                self.userIconView.user = SDGUser.simulatedCurrentUser
                self.connectingUserIconView.user = SDGUser.simulatedDiscoveredUser

                // Changes the delegate to self
                self.bluetoothManager.delegate = nil
            } else {
                self.simulationReminderTopConstraint.constant = -20
                self.simulationReminderView.hidden = true

                self.userIconView.user = SDGUser.currentUser
                self.connectingUserIconView.user = self.connectingUser

                // Changes the delegate to self
                self.bluetoothManager.delegate = self
            }
        }
    }

    @IBOutlet weak var connectingUserIconView: UserIconView!
    @IBOutlet weak var connectingUserHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var mutualUsersCollectionView: UICollectionView!

    @IBOutlet weak var simulationReminderView: UIView!
    @IBOutlet weak var simulationReminderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var numberOfConnectionsView: UIView!
    @IBOutlet weak var numberOfConnectionsLabel: UILabel!

    @IBOutlet weak var disconnectButton: UIButton!

    var connectingUser: SDGUser!
    var mutualUsers: [SDGUser] = []

    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager.sharedInstance
    var hud: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show/hide simulation enabled label
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let simulationEnabled: Bool = userDefaults.boolForKey(SDGSimulationEnabled)
        if simulationEnabled {
            self.displayMode = SDGDisplayMode.Simulated
        } else {
            self.displayMode = SDGDisplayMode.Normal
        }

        // Hides number of connections
        self.numberOfConnectionsView.alpha = 0
        self.numberOfConnectionsView.layer.cornerRadius = 10

        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
        self.mutualUsersCollectionView.addGestureRecognizer(longPressGesture)
        self.mutualUsersCollectionView.clipsToBounds = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.sharedApplication())
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.displayMode == SDGDisplayMode.Normal {
            // Send contacts
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                SDGContactsController.sharedInstance.promptForAddressBookAccessIfNeeded { (granted) in
                    if !granted {
                        SDGContactsController.sharedInstance.displayCantAddContactAlert(self)
                    } else {
                        self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: SDGUser.currentUser.contacts ?? [])

                        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        self.hud?.labelText = "Finding connections"
                    }
                }
            }
        } else {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.hud?.labelText = "Finding connections"

            // Wait 5 seconds
            // Compare contacts, and populate array
            let mutualUsers: [SDGUser] = self.getSimulatedContactUsers()
            self.mutualUsers = mutualUsers

            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.hud?.hide(true)

                // Show number of users
                self.numberOfConnectionsLabel.text = "\(self.mutualUsers.count)"

                UIView.animateWithDuration(1, delay: 0, options: .CurveLinear, animations: {
                    self.connectingUserHorizontalConstraint.constant -= 75
                    self.userIconHorizontalConstraint.constant += 75

                    self.numberOfConnectionsView.alpha = 1

                    self.mutualUsersCollectionView.reloadSections(NSIndexSet(index: 0))
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            })
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Compare the contacts with on the current device with another user
    func compareContacts(withUser user: SDGUser) -> [SDGUser] {

        var connections: [SDGUser] = []
        let contactsController: SDGContactsController = SDGContactsController.sharedInstance
        let matchedContacts: [CNContact] = contactsController.getCommonContactsWith(user.contacts ?? [])

        for contact: CNContact in matchedContacts {
            let matchedUsername: String = "\(contact.givenName) \(contact.familyName)"
            let matchedUser: SDGUser = SDGUser(peerId: MCPeerID(displayName: matchedUsername), color: UIColor.randomSDGColor())
            connections.append(matchedUser)
        }
        return connections
    }

    func getSimulatedContactUsers() -> [SDGUser] {
        var connections: [SDGUser] = []
        let matchedContacts: [CNContact] = SDGUser.simulatedDiscoveredUser.contacts ?? []

        for contact: CNContact in matchedContacts {
            let matchedUsername: String = "\(contact.givenName) \(contact.familyName)"
            let matchedUser: SDGUser = SDGUser(peerId: MCPeerID(displayName: matchedUsername), color: UIColor.randomSDGColor())
            connections.append(matchedUser)
        }
        return connections
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
                
                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "\(peer.displayName) have disconnected.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
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

                // Show number of connections
                self.numberOfConnectionsLabel.text = "\(self.mutualUsers.count)"

                UIView.animateWithDuration(1, delay: 0, options: .CurveLinear, animations: {
                    self.connectingUserHorizontalConstraint.constant -= 75
                    self.userIconHorizontalConstraint.constant += 75

                    self.numberOfConnectionsView.alpha = 1

                    self.mutualUsersCollectionView.reloadSections(NSIndexSet(index: 0))
                    self.view.layoutIfNeeded()
                    }, completion: nil)
                })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)

                self.showSimpleAlert("Connection", message: "No common connection.")
            })
        }
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        // If state is not connected, pop back to previous vc

        if state != .Connected {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)

                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "\(peerId.displayName) have disconnected.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                    // Disconnect self
                    self.bluetoothManager.session.disconnect()
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

    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {

    }

    func handleLongPressGesture(gesture: UILongPressGestureRecognizer?) {

        guard let location: CGPoint = gesture?.locationInView(self.mutualUsersCollectionView) else {
            return
        }

        if gesture?.state == .Began {
            if let selectedIndexPath: NSIndexPath = self.mutualUsersCollectionView.indexPathForItemAtPoint(location) {
                self.mutualUsersCollectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
            }
        } else if gesture?.state == .Changed {
            self.mutualUsersCollectionView.updateInteractiveMovementTargetPosition(location)
        } else if gesture?.state == .Ended {
            self.mutualUsersCollectionView.endInteractiveMovement()
        }
    }
}




