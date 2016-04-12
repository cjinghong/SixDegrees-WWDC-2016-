//
//  SDGBluetoothManager.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 08/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Contacts

protocol SDGBluetoothManagerDelegate {
    func didReceiveInvitationFromPeer(peerId: MCPeerID, completionBlock:((accept: Bool)->Void))
    func didReceiveContacts(contacts: [CNContact], fromPeer peer: MCPeerID)
    func foundPeer(peer: MCPeerID)
    func lostPeer(peer: MCPeerID)

    func peerDidChangeState(peerId: MCPeerID, state: MCSessionState)
}

class SDGBluetoothManager: NSObject {

    private let ServiceType = "sixdegrees-cjh"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)

    var session: MCSession!
//    lazy var session : MCSession = {
//        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
//        session.delegate = self
//        return session
//    }()

    private let serviceAdvetiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    var peersFound: [MCPeerID] = []

    var delegate: SDGBluetoothManagerDelegate?

    override init() {
        self.serviceAdvetiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: ServiceType)
        self.session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .Required)

        super.init()

        self.session.delegate = self
        self.serviceAdvetiser.delegate = self
        self.serviceBrowser.delegate = self
    }

    deinit {
        self.serviceAdvetiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func startAdvertising() {
        self.serviceAdvetiser.startAdvertisingPeer()
    }

    func startBrowsing() {
        self.serviceBrowser.startBrowsingForPeers()
    }

    func invitePeer(peerId: MCPeerID) {
        self.serviceBrowser.invitePeer(peerId, toSession: self.session, withContext: nil, timeout: 10)
    }

    func sendContactsToPeer(peerId: MCPeerID, contacts: [CNContact]) {
        let contactsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(contacts)
        do {
            try self.session.sendData(NSKeyedArchiver.archivedDataWithRootObject(contactsData), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Unable to send contacts data to \(peerId.displayName)")
        }


    }
}

extension SDGBluetoothManager : MCNearbyServiceAdvertiserDelegate {

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("Receive invitation from peer: \(peerID)")

        self.delegate?.didReceiveInvitationFromPeer(peerID, completionBlock: { (accept) in

            // Sends contact to the requesting user
            if accept {
                invitationHandler(true, self.session)
            } else {
                invitationHandler(false, MCSession(peer: peerID))
            }
        })
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Did not start advertising peer: \(error.localizedDescription)")
    }
}

extension SDGBluetoothManager : MCNearbyServiceBrowserDelegate {

    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID)")
        self.peersFound.append(peerID)
        self.delegate?.foundPeer(peerID)
    }

    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
        if let index: Int = self.peersFound.indexOf(peerID) {
            self.peersFound.removeAtIndex(index)
            self.delegate?.lostPeer(peerID)
        }
    }

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("Did not start browsing: \(error.localizedDescription)")
    }
}

extension MCSessionState {
    func toString() -> String {
        switch self {
        case .NotConnected:
            return "Not Connected"
        case .Connected:
            return "Connected"
        case .Connecting:
            return "Connecting"
        }
    }
}

extension SDGBluetoothManager : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("Peer: \(peerID) Changed state: \(state.toString())")
        self.delegate?.peerDidChangeState(peerID, state: state)
    }

    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }

    // TODO: - Figure out why unable to convert NSData back to CNContact (http://stackoverflow.com/questions/36546221/converting-cncontact-to-nsdata-and-vice-versa)
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("Received data: \(data) From Peer: \(peerID)")

        if let contactsData: NSData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSData {
            if let contacts: [CNContact] = NSKeyedUnarchiver.unarchiveObjectWithData(contactsData) as? [CNContact] {
                self.delegate?.didReceiveContacts(contacts, fromPeer: peerID)
            }
        }

//        let keyedUnarchiver = NSKeyedUnarchiver(forReadingWithData: data)
    }

    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream: \(stream)")
    }

    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("Start receiving resource: \(resourceName)")
    }

    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("Finished receiving resource: \(resourceName)")
    }
}


