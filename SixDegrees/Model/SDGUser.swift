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

    var peerId: MCPeerID!
    var name: String!

    var contacts: [CNContact]?

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