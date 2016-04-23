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

class ConnectionsViewController: UIViewController {

    @IBOutlet weak var connectingUserIconView: UserIconView!
    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var findConnectionsButton: UIButton!

    var connectingUser: SDGUser!
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager.sharedInstance

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

    @IBAction func findConnections(sender: AnyObject) {
        
    }

}

extension ConnectionsViewController: SDGBluetoothManagerDelegate {

    func foundPeer(peer: MCPeerID) {
        return
    }

    func lostPeer(peer: MCPeerID) {
        return
    }

    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock:((accept: Bool)->Void)) {
        // Automatically reject invitation if aleady in a session
        completionBlock(accept: false)
    }

    func didReceiveContacts(contacts: [CNContact], fromPeer peer: MCPeerID) {
        self.connectingUser.contacts = contacts

        // Compare contacts
        let connections: [SDGUser] = self.compareContacts(withUser: self.connectingUser)

        // TODO: Draw connections
        if !connections.isEmpty {
            
        }
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        // If state is not connected, pop back to previous vc

        if state != .Connected {
            let alertController: UIAlertController = UIAlertController(title: "Disconnected", message: "You have disconnected from \(peerId.displayName). Please do not turn off the wifi of both the devices.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                // Disconnect self, then pop back to vc.
                self.bluetoothManager.session.disconnect()
//                self.navigationController?.popViewControllerAnimated(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}




