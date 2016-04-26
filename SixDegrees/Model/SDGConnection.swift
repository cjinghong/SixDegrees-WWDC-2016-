//
//  SDGConnection.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 26/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import CoreData
import MultipeerConnectivity

class SDGConnection: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var myUserName: String
    @NSManaged var targetUserName: String
    @NSManaged var mutualUserNames: [String]

    var myUser: SDGUser? {
        get {
            let user = SDGUser(peerId: MCPeerID(displayName: self.myUserName) , color: UIColor.randomSDGColor())
            return user
        }
    }
    var targetUser: SDGUser? {
        get {
            let user = SDGUser(peerId: MCPeerID(displayName: self.targetUserName) , color: UIColor.randomSDGColor())
            return user
        }
    }
    var mutualUsers: [SDGUser] {
        get {
            var mutualUsers: [SDGUser] = []
            for username in self.mutualUserNames {
                let user = SDGUser(peerId: MCPeerID(displayName: username) , color: UIColor.randomSDGColor())
                mutualUsers.append(user)
            }
            return mutualUsers
        }
    }

//    init(myUserName: String, targetUserName: String, mutualUsers: [String] = []) {
//        super.init(entity: <#T##NSEntityDescription#>, insertIntoManagedObjectContext: <#T##NSManagedObjectContext?#>)
//
//        self.myUserName = myUserName
//        self.targetUserName = targetUserName
//        self.mutualUsers = mutualUsers
//    }

}