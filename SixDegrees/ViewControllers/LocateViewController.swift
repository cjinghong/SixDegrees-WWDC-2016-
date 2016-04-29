//
//  ViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

import Contacts
import MultipeerConnectivity
import MBProgressHUD
import Pulsator

enum SDGDisplayMode {
    case Normal
    case Simulated
}

class LocateViewController: UIViewController {

    var displayMode: SDGDisplayMode! {
        didSet {
            if displayMode == SDGDisplayMode.Simulated {
                self.simulationReminderTopConstraint.constant = 0

                // Reset all data
                self.userIconView.user = SDGUser.simulatedCurrentUser
                self.discoveredUsers = [SDGUser.simulatedDiscoveredUser]
                self.hideSearchingForNearbyDevices()
                self.discoveredUsersCollectionView.reloadData()

                // Stop advertising and browsing for devices
                self.bluetoothManager.stopBrowsing()
                self.bluetoothManager.stopAdvertising()
                self.bluetoothManager.delegate = nil

            } else {
                self.simulationReminderTopConstraint.constant = -20

                self.userIconView.user = SDGUser.currentUser
                self.discoveredUsers.removeAll()
                self.discoveredUsersCollectionView.reloadData()

                // Start advertising and browsing for devices
                self.bluetoothManager.delegate = self
                self.bluetoothManager.startAdvertising()
                self.bluetoothManager.startBrowsing()
            }
        }
    }

    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!
    var originalUserIconHorizontalConstraint: CGFloat?
    @IBOutlet weak var findConnectionsButton: UIButton!
    @IBOutlet weak var findConnectionsBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var discoveredUsersCollectionView: UICollectionView!
    @IBOutlet weak var connectionFailedView: UIView!
    @IBOutlet weak var simulationReminderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchingForDevicesLabel: UILabel!
    @IBOutlet weak var turnOnWifiReminderLabel: UILabel!

    let contactsController: SDGContactsController = SDGContactsController.sharedInstance
    let bluetoothManager: SDGBluetoothManager = SDGBluetoothManager.sharedInstance

    var discoveredUsers: [SDGUser] = []
    var userIconViews: [UserIconView] = []
    var originalChosenUserIconFrame: CGRect?

    // Collectionview animation variables
    var userOriginalIndexPath: NSIndexPath?
    var userCurrentIndexPath: NSIndexPath?

    // Loading HUD
    var hud: MBProgressHUD?
    let pulsator: Pulsator = Pulsator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set display mode
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let simulationEnabled: Bool = userDefaults.boolForKey(SDGSimulationEnabled)
        if simulationEnabled {
            self.displayMode = SDGDisplayMode.Simulated
        } else {
            self.displayMode = SDGDisplayMode.Normal
        }

        self.view.backgroundColor = UIColor.SDGLightBlue()

        self.connectionFailedView.hidden = true
        self.searchingForDevicesLabel.hidden = true
        self.turnOnWifiReminderLabel.hidden = true

        self.pulsator.numPulse = 4
        self.pulsator.radius = self.view.frame.width/2 - 10
        self.pulsator.backgroundColor = UIColor.SDGDarkBlue().CGColor
        self.pulsator.frame.origin.x += 35
        self.pulsator.frame.origin.y += 35
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.sharedApplication())

        // Store reference of the userIconHorizontalConstraint
        self.originalUserIconHorizontalConstraint = self.userIconHorizontalConstraint.constant

        if self.discoveredUsers.isEmpty {
            self.showSearchingForNearbyDevices()
        } else {
            self.hideSearchingForNearbyDevices()
        }

        // Show/hide simulation enabled label
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let simulationEnabled: Bool = userDefaults.boolForKey(SDGSimulationEnabled)
        if simulationEnabled {
            // If display mode is not already simulated, simulate.
            if self.displayMode != SDGDisplayMode.Simulated {
                self.displayMode = SDGDisplayMode.Simulated
            }
        } else {
            // If display mode is not already normal, make it normal.
            if self.displayMode != SDGDisplayMode.Normal {
                self.displayMode = SDGDisplayMode.Normal
            }
        }
    }

    override func viewDidAppear(animated: Bool) {

        self.userIconView.layer.insertSublayer(self.pulsator, below: userIconView.iconImageView.layer)

        self.pulsator.start()

        // Try to get access to all the contacts of the current device
        self.contactsController.promptForAddressBookAccessIfNeeded { (granted) in
            if !granted {
                self.contactsController.displayCantAddContactAlert(self)
            } else {
                SDGUser.currentUser.contacts = self.contactsController.contacts
            }
        }
    }

    // MARK: - Functions

    @IBAction func findConnections(sender: AnyObject) {
        if let contacts = SDGUser.currentUser.contacts {
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: contacts)
            }
        }
    }

    // MARK: - Animation functions
    func showConnectionFailedView() {

        // Error view
        self.connectionFailedView.alpha = 0
        self.connectionFailedView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.connectionFailedView.hidden = false

        // Animation block
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.connectionFailedView.transform = CGAffineTransformIdentity
            self.connectionFailedView.alpha = 1

            }, completion: {(success: Bool) in
                UIView.animateWithDuration(0.6, delay: 3, usingSpringWithDamping: 0.4, initialSpringVelocity: 4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.connectionFailedView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    self.connectionFailedView.alpha = 0

                    }, completion: {(success: Bool) in
                        self.connectionFailedView.hidden = true
                })
        })
    }

    func showSearchingForNearbyDevices() {
        self.searchingForDevicesLabel.alpha = 0
        self.searchingForDevicesLabel.hidden = false

        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { 
            self.searchingForDevicesLabel.alpha = 1
        }) { (success: Bool) in
            // Wait 10 seconds, if users still empty, suggest to turn on wifi
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue(), {
                if self.discoveredUsers.isEmpty {
                    self.showTurnOnWifiReminderLabel()
                }
            })
        }
    }

    func hideSearchingForNearbyDevices() {
        self.hideTurnOnWifiReminderLabel()
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.searchingForDevicesLabel.alpha = 0
        }) { (success: Bool) in
                self.searchingForDevicesLabel.hidden = true
        }
    }

    func showTurnOnWifiReminderLabel() {
        self.turnOnWifiReminderLabel.alpha = 0
        self.turnOnWifiReminderLabel.hidden = false

        UIView.animateWithDuration(0.5, animations: {
            self.turnOnWifiReminderLabel.alpha = 1
            }, completion: nil)
    }

    func hideTurnOnWifiReminderLabel() {
        UIView.animateWithDuration(0.3, animations: {
            self.turnOnWifiReminderLabel.alpha = 0
            }, completion: {(success: Bool) in
                self.turnOnWifiReminderLabel.hidden = true
        })
    }
}

// MARK: - SDGBluetoothManagerDelegate
extension LocateViewController : SDGBluetoothManagerDelegate {

    func foundPeer(peer: MCPeerID) {
        dispatch_async(dispatch_get_main_queue(), {
            if self.discoveredUsers.isEmpty {
                self.showSearchingForNearbyDevices()
            } else {
                self.hideSearchingForNearbyDevices()
            }
        })

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
                    self.discoveredUsers.removeAtIndex(self.discoveredUsers.indexOf(user)!)
                    self.discoveredUsersCollectionView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.discoveredUsersCollectionView.numberOfSections())))
                })
            }
        }

        dispatch_async(dispatch_get_main_queue(), {
            if self.discoveredUsers.isEmpty {
                self.showSearchingForNearbyDevices()
            } else {
                self.hideSearchingForNearbyDevices()
            }
        })
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
        return
    }

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState) {
        if state == .Connected {
            // Animation should be pushed to the main queue
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)

                let user = self.discoveredUsers.filter({ (aUser: SDGUser) -> Bool in
                    return aUser.peerId == peerId
                }).first

                if let user = user {
                    let connectionsVC: ConnectionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ConnectionsViewController") as! ConnectionsViewController
                    connectionsVC.connectingUser = self.discoveredUsers[self.discoveredUsers.indexOf(user)!]
                    self.presentViewController(connectionsVC, animated: true, completion: nil)
                }
            })
        } else if state == .Connecting {
            let user: SDGUser? = self.discoveredUsers.filter({ (user: SDGUser) -> Bool in
                user.peerId == peerId
            }).first

            // Animation should be pushed to the main queue
            // Fade out all cells, except the connecting user
            dispatch_async(dispatch_get_main_queue(), {
                if let user = user {

                    for i in 0..<self.discoveredUsersCollectionView.numberOfItemsInSection(0) {
                        if i != self.discoveredUsers.indexOf(user)! {
                            let cell: UICollectionViewCell = self.discoveredUsersCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0))!
                            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                                cell.alpha = 0
                            }, completion: nil)
                        }
                    }
                }
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.hud?.labelText = "Connecting"
            })
        } else if state == .NotConnected {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)
                self.showConnectionFailedView()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.hud?.hide(true)
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
        return self.discoveredUsers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell

        // Reset cell
        cell.hidden = false
        if indexPath.row < self.discoveredUsers.count {
            cell.user = self.discoveredUsers[indexPath.row]
        } else {
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
        let user: SDGUser = self.discoveredUsers[indexPath.row]
        let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Do you wish to connect with \(user.name)?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

        // Change action of OK button based on display mode
        if self.displayMode == SDGDisplayMode.Normal {
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.bluetoothManager.invitePeer(user.peerId)
            }))
        } else {

            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                // Stop for 1 sec, then present vc
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.hud?.labelText = "Connecting"
                let disptachTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))

                dispatch_after(disptachTime, dispatch_get_main_queue(), {
                    self.hud?.hide(true)
                    let connectionsVC: ConnectionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ConnectionsViewController") as! ConnectionsViewController
                    connectionsVC.connectingUser = self.discoveredUsers[self.discoveredUsers.indexOf(user)!]
                    self.presentViewController(connectionsVC, animated: true, completion: nil)
                })
            }))
        }

        self.presentViewController(alertController, animated: true, completion: nil)
    }


}





