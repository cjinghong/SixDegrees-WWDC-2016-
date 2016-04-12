//
//  User.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 02/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import SwiftyJSON
import MultipeerConnectivity
import Contacts

public class SDGUser {

    static let currentUser = SDGUser(peerId: MCPeerID(displayName: UIDevice.currentDevice().name))

    var peerId: MCPeerID!
    var name: String!
    var contacts: [CNContact]?

    // This is used to identify the user when matching contacts. Could be an email, phone number, or other details
    // TODO: - Encrypt this?
    var identifierString: String?

    init(peerId: MCPeerID) {
        self.peerId = peerId
        self.name = peerId.displayName
    }

}

extension SDGUser : Equatable {}

public func == (lhs: SDGUser, rhs: SDGUser) -> Bool {
    let sameUser: Bool = (lhs.peerId == rhs.peerId)
    return sameUser
}