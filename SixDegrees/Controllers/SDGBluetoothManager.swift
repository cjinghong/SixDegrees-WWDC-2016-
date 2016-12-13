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
    func didReceiveInvitationFromPeer(_ peerId: MCPeerID, completionBlock: @escaping ((_ accept: Bool)->Void))
    func didReceiveContacts(_ contacts: [CNContact], fromPeer peer: MCPeerID)
    func foundPeer(_ peer: MCPeerID)
    func lostPeer(_ peer: MCPeerID)

    func peerDidChangeState(_ peerId: MCPeerID, state: MCSessionState)
}

class SDGBluetoothManager: NSObject {

    static let sharedInstance = SDGBluetoothManager()
    
    fileprivate let ServiceType = "sixdegrees-cjh"
    fileprivate let myPeerId = MCPeerID(displayName: UIDevice.current.name)

    var session: MCSession!

    fileprivate let serviceAdvetiser: MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser: MCNearbyServiceBrowser

    var peersFound: [MCPeerID] = []

    var delegate: SDGBluetoothManagerDelegate?

    override init() {
        self.serviceAdvetiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: ServiceType)
        self.session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)

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

    func stopAdvertising() {
        self.serviceAdvetiser.stopAdvertisingPeer()
    }

    func stopBrowsing() {
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func invitePeer(_ peerId: MCPeerID) {
        self.serviceBrowser.invitePeer(peerId, to: self.session, withContext: nil, timeout: 10)
    }

    func sendContactsToPeer(_ peerId: MCPeerID, contacts: [CNContact]) {
        let contactsData: Data = NSKeyedArchiver.archivedData(withRootObject: contacts)
        do {
            try self.session.send(NSKeyedArchiver.archivedData(withRootObject: contactsData), toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print("Unable to send contacts data to \(peerId.displayName)")
        }


    }
}

extension SDGBluetoothManager : MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
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

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Did not start advertising peer: \(error.localizedDescription)")
    }
}

extension SDGBluetoothManager : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID)")
        self.peersFound.append(peerID)
        self.delegate?.foundPeer(peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
        if let index: Int = self.peersFound.index(of: peerID) {
            self.peersFound.remove(at: index)
            self.delegate?.lostPeer(peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing: \(error.localizedDescription)")
    }
}

extension MCSessionState {
    func toString() -> String {
        switch self {
        case .notConnected:
            return "Not Connected"
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        }
    }
}

extension SDGBluetoothManager : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer: \(peerID) Changed state: \(state.toString())")
        self.delegate?.peerDidChangeState(peerID, state: state)
    }

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let contactsData: Data = NSKeyedUnarchiver.unarchiveObject(with: data) as? Data {
            if let contacts: [CNContact] = NSKeyedUnarchiver.unarchiveObject(with: contactsData) as? [CNContact] {
                self.delegate?.didReceiveContacts(contacts, fromPeer: peerID)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream: \(stream)")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Start receiving resource: \(resourceName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("Finished receiving resource: \(resourceName)")
    }
}


