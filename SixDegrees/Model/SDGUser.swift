//
//  User.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 02/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Contacts

open class SDGUser {

    static let currentUser = SDGUser(peerId: MCPeerID(displayName: UIDevice.current.name), color: UIColor.SDGPeach())

    // Simulation
    static let simulatedCurrentUser = SDGUser(peerId: MCPeerID(displayName: UIDevice.current.name), color: UIColor.SDGPeach(), simulated: true)
    static let simulatedDiscoveredUser = SDGUser(peerId: MCPeerID(displayName: "John Appleseed"), color: UIColor.SDGGreen(), simulated: true)

    var peerId: MCPeerID!
    var name: String!
    var contacts: [CNContact]?

    var identifier: String?

    var color: UIColor?

    init(peerId: MCPeerID, color: UIColor) {
        self.peerId = peerId
        self.name = peerId.displayName
        self.color = color
    }

    // Initializing a simulated user is only allowed for self
    fileprivate init(peerId: MCPeerID, color: UIColor, simulated: Bool) {
        self.peerId = peerId
        self.name = peerId.displayName
        self.color = color

        if simulated {
            let contact: CNMutableContact = CNMutableContact()
            contact.givenName = "Steve J"
            contact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "245478451")))
            let contact2: CNMutableContact = CNMutableContact()
            contact2.givenName = "Bill A"
            contact2.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "478152489")))
            let contact3: CNMutableContact = CNMutableContact()
            contact3.givenName = "Bob B"
            contact3.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "794854215")))
            self.contacts = [contact, contact2, contact3]
        }
    }

    class func simulatedUsernames() -> [String] {
        var connections: [String] = []
        let matchedContacts: [CNContact] = SDGUser.simulatedDiscoveredUser.contacts ?? []

        for contact: CNContact in matchedContacts {
            let matchedUsername: String = "\(contact.givenName) \(contact.familyName)"
            connections.append(matchedUsername)
        }
        return connections
    }

}

extension SDGUser : Equatable {}

public func == (lhs: SDGUser, rhs: SDGUser) -> Bool {
    let sameUser: Bool = (lhs.peerId == rhs.peerId)
    return sameUser
}
