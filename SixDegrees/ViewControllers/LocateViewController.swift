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

    var peers: [MCPeerID] = []

    override func viewDidLoad() {
        super.viewDidLoad()
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
}

extension LocateViewController : SDGBluetoothManagerDelegate {

    func didUpdatePeers(peers: [MCPeerID]) {
        if self.peers == [] {
            self.peers = peers
        } else {
            // Compare the missing peers and make it disspear
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

    func didReceiveContacts(contacts: [CNContact]) {
        
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


