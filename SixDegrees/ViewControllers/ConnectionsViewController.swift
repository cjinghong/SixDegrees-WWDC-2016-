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
            if displayMode == SDGDisplayMode.simulated {
                self.simulationReminderTopConstraint.constant = 0
                self.simulationReminderView.isHidden = false

                self.userIconView.user = SDGUser.simulatedCurrentUser
                self.connectingUserIconView.user = SDGUser.simulatedDiscoveredUser

                // Changes the delegate to self
                self.bluetoothManager.delegate = nil
            } else {
                self.simulationReminderTopConstraint.constant = -20
                self.simulationReminderView.isHidden = true

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
        let userDefaults: UserDefaults = UserDefaults.standard
        let simulationEnabled: Bool = userDefaults.bool(forKey: SDGSimulationEnabled)
        if simulationEnabled {
            self.displayMode = SDGDisplayMode.simulated
        } else {
            self.displayMode = SDGDisplayMode.normal
        }

        // Hides number of connections
        self.numberOfConnectionsView.alpha = 0
        self.numberOfConnectionsView.layer.cornerRadius = 10

        // Add long press to collection view for reordering
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
        self.mutualUsersCollectionView.addGestureRecognizer(longPressGesture)
        self.mutualUsersCollectionView.clipsToBounds = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.shared)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.displayMode == SDGDisplayMode.normal {
            // Send contacts
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                SDGContactsController.sharedInstance.promptForAddressBookAccessIfNeeded { (granted) in
                    if !granted {
                        SDGContactsController.sharedInstance.displayCantAddContactAlert(self)
                    } else {
                        self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: SDGUser.currentUser.contacts ?? [])

                        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        self.hud?.label.text = "Finding connections"
                    }
                }
            }
        } else {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud?.label.text = "Finding connections"

            // Wait 5 seconds
            // Compare contacts, and populate array
            let mutualUsers: [SDGUser] = self.getSimulatedContactUsers()
            self.mutualUsers = mutualUsers

            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.hud?.hide(animated: true)

                // Show number of users
                self.numberOfConnectionsLabel.text = "\(self.mutualUsers.count)"

                UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                    self.connectingUserHorizontalConstraint.constant -= 75
                    self.userIconHorizontalConstraint.constant += 75

                    self.numberOfConnectionsView.alpha = 1

                    self.mutualUsersCollectionView.reloadSections(IndexSet(integer: 0))
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
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
            matchedUser.identifier = (contact.emailAddresses.first?.value as String?) ?? (contact.phoneNumbers.first?.value.stringValue)
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
            matchedUser.identifier = (contact.emailAddresses.first?.value as String?) ?? (contact.phoneNumbers.first?.value.stringValue)
            connections.append(matchedUser)
        }
        return connections
    }

    @IBAction func disconnect(_ sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "Disconnect", message: "Are you sure you want to disconnect from the current session?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
            // Disconnect self, then pop back to vc.
            self.bluetoothManager.session.disconnect()
            self.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) in
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension ConnectionsViewController: SDGBluetoothManagerDelegate {

    func foundPeer(_ peer: MCPeerID) {
        return
    }

    func lostPeer(_ peer: MCPeerID) {
        // If the lost peer is the connecting user, disconnect
        if peer == self.connectingUser.peerId {
            DispatchQueue.main.async(execute: {
                self.hud?.hide(animated: true)
                
                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "\(peer.displayName) have disconnected.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                }))
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }

    func didReceiveInvitationFromPeer(_ peerId: MCPeerID, completionBlock: @escaping ((_ accept: Bool)->Void)) {
        // Automatically reject invitation if aleady in a session
        completionBlock(false)
    }

    func didReceiveContacts(_ contacts: [CNContact], fromPeer peer: MCPeerID) {
        self.connectingUser.contacts = contacts

        // Compare contacts, and populate array
        let mutualUsers: [SDGUser] = self.compareContacts(withUser: self.connectingUser)
        self.mutualUsers = mutualUsers

        // Save connection to Core Data
        let MOC: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let connection: SDGConnection = NSEntityDescription.insertNewObject(forEntityName: "SDGConnection", into: MOC) as! SDGConnection
        connection.date = Date()
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
            DispatchQueue.main.async(execute: {
                self.hud?.hide(animated: true)

                // Show number of connections
                self.numberOfConnectionsLabel.text = "\(self.mutualUsers.count)"

                UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                    self.connectingUserHorizontalConstraint.constant -= 75
                    self.userIconHorizontalConstraint.constant += 75

                    self.numberOfConnectionsView.alpha = 1

                    self.mutualUsersCollectionView.reloadSections(IndexSet(integer: 0))
                    self.view.layoutIfNeeded()
                    }, completion: nil)
                })
        } else {
            DispatchQueue.main.async(execute: {
                self.hud?.hide(animated: true)

                self.showSimpleAlert("Connection", message: "No common connection.")
            })
        }
    }

    func peerDidChangeState(_ peerId: MCPeerID, state: MCSessionState) {
        // If state is not connected, pop back to previous vc

        if state != .connected {
            DispatchQueue.main.async(execute: {
                self.hud?.hide(animated: true)

                let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "\(peerId.displayName) have disconnected.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                    // Disconnect self
                    self.bluetoothManager.session.disconnect()
                }))
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
}

extension ConnectionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mutualUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.user = self.mutualUsers[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            if i != indexPath.row {
                let cell: UserCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! UserCollectionViewCell
                if cell.detailsShowing == true {
                    cell.hideDetails()
                }
            }
        }

        let cell: UserCollectionViewCell = collectionView.cellForItem(at: indexPath) as! UserCollectionViewCell
        if cell.detailsShowing {
            cell.hideDetails()
        } else {
            cell.showDetails()
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        swap(&self.mutualUsers[sourceIndexPath.row], &self.mutualUsers[destinationIndexPath.row])
    }

    func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer?) {

        guard let location: CGPoint = gesture?.location(in: self.mutualUsersCollectionView) else {
            return
        }

        if gesture?.state == .began {
            if let selectedIndexPath: IndexPath = self.mutualUsersCollectionView.indexPathForItem(at: location) {
                self.mutualUsersCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            }
        } else if gesture?.state == .changed {
            self.mutualUsersCollectionView.updateInteractiveMovementTargetPosition(location)
        } else if gesture?.state == .ended {
            self.mutualUsersCollectionView.endInteractiveMovement()
        }
    }
}


