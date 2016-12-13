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
    case normal
    case simulated
}

class LocateViewController: UIViewController {

    var displayMode: SDGDisplayMode! {
        didSet {
            if displayMode == SDGDisplayMode.simulated {
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
    var userOriginalIndexPath: IndexPath?
    var userCurrentIndexPath: IndexPath?

    // Loading HUD
    var hud: MBProgressHUD?
    let pulsator: Pulsator = Pulsator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set display mode
        let userDefaults: UserDefaults = UserDefaults.standard
        let simulationEnabled: Bool = userDefaults.bool(forKey: SDGSimulationEnabled)
        if simulationEnabled {
            self.displayMode = SDGDisplayMode.simulated
        } else {
            self.displayMode = SDGDisplayMode.normal
        }

        self.view.backgroundColor = UIColor.SDGLightBlue()

        self.connectionFailedView.isHidden = true
        self.searchingForDevicesLabel.isHidden = true
        self.turnOnWifiReminderLabel.isHidden = true

        // Setup pulsator
        self.pulsator.numPulse = 4
        self.pulsator.radius = self.view.frame.width/2 - 10
        self.pulsator.backgroundColor = UIColor.SDGDarkBlue().cgColor
        self.pulsator.frame.origin.x += 35
        self.pulsator.frame.origin.y += 35
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customize app theme
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.customizeAppearance(UIApplication.shared)

        // Store reference of the userIconHorizontalConstraint
        self.originalUserIconHorizontalConstraint = self.userIconHorizontalConstraint.constant

        if self.discoveredUsers.isEmpty {
            self.showSearchingForNearbyDevices()
        } else {
            self.hideSearchingForNearbyDevices()
        }

        // Pulse
        self.userIconView.layer.insertSublayer(self.pulsator, below: userIconView.iconImageView.layer)
        self.pulsator.start()

        // Show/hide simulation enabled label
        let userDefaults: UserDefaults = UserDefaults.standard
        let simulationEnabled: Bool = userDefaults.bool(forKey: SDGSimulationEnabled)
        if simulationEnabled {
            // If display mode is not already simulated, simulate.
            if self.displayMode != SDGDisplayMode.simulated {
                self.displayMode = SDGDisplayMode.simulated
            }
        } else {
            // If display mode is not already normal, make it normal.
            if self.displayMode != SDGDisplayMode.normal {
                self.displayMode = SDGDisplayMode.normal
            }
            // Restart bluetooth services if needed
            self.restartBTServicesIfNeeded()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
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
    @IBAction func findConnections(_ sender: AnyObject) {
        if let contacts = SDGUser.currentUser.contacts {
            if let connectedPeer = self.bluetoothManager.session.connectedPeers.first {
                self.bluetoothManager.sendContactsToPeer(connectedPeer, contacts: contacts)
            }
        }
    }

    /// Stops advertising and browsing, and starts again.
    func restartBTServicesIfNeeded() {
        self.bluetoothManager.stopBrowsing()
        self.bluetoothManager.stopAdvertising()
        self.discoveredUsers.removeAll()

        self.bluetoothManager.startBrowsing()
        self.bluetoothManager.startAdvertising()

        self.bluetoothManager.delegate = self
    }

    // MARK: - Animation functions
    func showConnectionFailedView() {

        // Error view
        self.connectionFailedView.alpha = 0
        self.connectionFailedView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.connectionFailedView.isHidden = false

        // Animation block
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 4, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.connectionFailedView.transform = CGAffineTransform.identity
            self.connectionFailedView.alpha = 1

            }, completion: {(success: Bool) in
                UIView.animate(withDuration: 0.6, delay: 3, usingSpringWithDamping: 0.4, initialSpringVelocity: 4, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.connectionFailedView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    self.connectionFailedView.alpha = 0

                    }, completion: {(success: Bool) in
                        self.connectionFailedView.isHidden = true
                })
        })
    }

    func showSearchingForNearbyDevices() {
        self.searchingForDevicesLabel.alpha = 0
        self.searchingForDevicesLabel.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { 
            self.searchingForDevicesLabel.alpha = 1
        }) { (success: Bool) in
            // Wait 10 seconds, if users still empty, suggest to turn on wifi
            let time = DispatchTime.now() + Double(Int64(10 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if self.discoveredUsers.isEmpty {
                    self.showTurnOnWifiReminderLabel()
                }
            })
        }
    }

    func hideSearchingForNearbyDevices() {
        self.hideTurnOnWifiReminderLabel()
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.searchingForDevicesLabel.alpha = 0
        }) { (success: Bool) in
                self.searchingForDevicesLabel.isHidden = true
        }
    }

    func showTurnOnWifiReminderLabel() {
        self.turnOnWifiReminderLabel.alpha = 0
        self.turnOnWifiReminderLabel.isHidden = false

        UIView.animate(withDuration: 0.5, animations: {
            self.turnOnWifiReminderLabel.alpha = 1
            }, completion: nil)
    }

    func hideTurnOnWifiReminderLabel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.turnOnWifiReminderLabel.alpha = 0
            }, completion: {(success: Bool) in
                self.turnOnWifiReminderLabel.isHidden = true
        })
    }

//    func handleLongPressGesture(gesture: UILongPressGestureRecognizer?) {
//
//        guard let location: CGPoint = gesture?.locationInView(self.discoveredUsersCollectionView) else {
//            return
//        }
//
//        if gesture?.state == .Began {
//            if let selectedIndexPath: NSIndexPath = self.discoveredUsersCollectionView.indexPathForItemAtPoint(location) {
//                self.discoveredUsersCollectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
//            }
//        } else if gesture?.state == .Changed {
//            self.discoveredUsersCollectionView.updateInteractiveMovementTargetPosition(location)
//        } else {
//            self.discoveredUsersCollectionView.endInteractiveMovement()
//        }
//    }
}

// MARK: - SDGBluetoothManagerDelegate
extension LocateViewController : SDGBluetoothManagerDelegate {

    func foundPeer(_ peer: MCPeerID) {
        DispatchQueue.main.async(execute: {
            if self.discoveredUsers.isEmpty {
                self.showSearchingForNearbyDevices()
            } else {
                self.hideSearchingForNearbyDevices()
            }
        })

        let user: SDGUser = SDGUser(peerId: peer, color: UIColor.randomSDGColor())
        if !self.discoveredUsers.contains(user) {
            self.discoveredUsers.append(user)
            self.discoveredUsersCollectionView.cancelInteractiveMovement()
            self.discoveredUsersCollectionView.reloadData()
        }
    }

    func lostPeer(_ peer: MCPeerID) {

        for user in self.discoveredUsers {
            if user.peerId == peer {
                // Animation should be pushed to the main queue
                DispatchQueue.main.async(execute: {
                    self.discoveredUsers.remove(at: self.discoveredUsers.index(of: user)!)
                    self.discoveredUsersCollectionView.reloadSections(IndexSet(integersIn: NSMakeRange(0, self.discoveredUsersCollectionView.numberOfSections).toRange()!))
                })
            }
        }

        DispatchQueue.main.async(execute: {
            if self.discoveredUsers.isEmpty {
                self.showSearchingForNearbyDevices()
            } else {
                self.hideSearchingForNearbyDevices()
            }
        })
    }

    func didReceiveInvitationFromPeer(_ peerId: MCPeerID, completionBlock: @escaping ((_ accept: Bool) -> Void)) {
        
        let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Invitation from \(peerId.displayName)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
            completionBlock(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) in
            completionBlock(false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    func didReceiveContacts(_ contacts: [CNContact], fromPeer peer: MCPeerID) {
        return
    }

    func peerDidChangeState(_ peerId: MCPeerID, state: MCSessionState) {
        if state == .connected {
            // Animation should be pushed to the main queue
            DispatchQueue.main.async(execute: {
                self.hud?.hide(true)

                let user = self.discoveredUsers.filter({ (aUser: SDGUser) -> Bool in
                    return aUser.peerId == peerId
                }).first

                if let user = user {
                    let connectionsVC: ConnectionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConnectionsViewController") as! ConnectionsViewController
                    connectionsVC.connectingUser = self.discoveredUsers[self.discoveredUsers.index(of: user)!]
                    self.present(connectionsVC, animated: true, completion: nil)
                }
            })
        } else if state == .connecting {
            let user: SDGUser? = self.discoveredUsers.filter({ (user: SDGUser) -> Bool in
                user.peerId == peerId
            }).first

            // Animation should be pushed to the main queue
            // Fade out all cells, except the connecting user
            DispatchQueue.main.async(execute: {
                if let user = user {

                    for i in 0..<self.discoveredUsersCollectionView.numberOfItems(inSection: 0) {
                        if i != self.discoveredUsers.index(of: user)! {
                            let cell: UICollectionViewCell = self.discoveredUsersCollectionView.cellForItem(at: IndexPath(item: i, section: 0))!
                            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                                cell.alpha = 0
                            }, completion: nil)
                        }
                    }
                }
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud?.labelText = "Connecting"
            })
        } else if state == .notConnected {
            DispatchQueue.main.async(execute: {
                self.hud?.hide(true)
                self.showConnectionFailedView()
            })
        } else {
            DispatchQueue.main.async(execute: {
                self.hud?.hide(true)
            })
        }
    }
}

// MARK: - CollectionView Datasource and Delegate
extension LocateViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func indexPathForClosestCell() -> IndexPath? {
        let screenCenterX: CGFloat = self.view.center.x
        let bottomOfCollectionView: CGFloat = self.discoveredUsersCollectionView.frame.origin.x + self.discoveredUsersCollectionView.frame.size.height - 8 // Give extra 8 pixels so it wouldnt go outside of the collecitonview

        let closestPointInView: CGPoint = CGPoint(x: screenCenterX, y: bottomOfCollectionView)
        let closestPointInCollectionView: CGPoint = self.view.convert(closestPointInView, to: self.discoveredUsersCollectionView)

        return self.discoveredUsersCollectionView.indexPathForItem(at: closestPointInCollectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.discoveredUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell

        // Reset cell
        cell.isHidden = false
        if indexPath.row < self.discoveredUsers.count {
            cell.user = self.discoveredUsers[indexPath.row]
        } else {
            cell.isHidden = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Animate cell appearing
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1
        }) { (success: Bool) in
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user: SDGUser = self.discoveredUsers[indexPath.row]
        let alertController: UIAlertController = UIAlertController(title: "Connect", message: "Do you wish to connect with \(user.name)?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        // Change action of OK button based on display mode
        if self.displayMode == SDGDisplayMode.normal {
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                self.bluetoothManager.invitePeer(user.peerId)
            }))
        } else {

            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                // Stop for 1 sec, then present vc
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud?.labelText = "Connecting"
                let disptachTime: DispatchTime = DispatchTime.now() + Double(Int64(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)

                DispatchQueue.main.asyncAfter(deadline: disptachTime, execute: {
                    self.hud?.hide(true)
                    let connectionsVC: ConnectionsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConnectionsViewController") as! ConnectionsViewController
                    connectionsVC.connectingUser = self.discoveredUsers[self.discoveredUsers.index(of: user)!]
                    self.present(connectionsVC, animated: true, completion: nil)
                })
            }))
        }

        self.present(alertController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
}





