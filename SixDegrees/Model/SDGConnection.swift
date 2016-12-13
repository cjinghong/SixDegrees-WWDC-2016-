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

    @NSManaged var date: Date
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

    /// Using this init enables you to init an SDGConnection object without saving to Core Data
    convenience init(date: Date, myUsername: String, targetUsername: String, mutualUsernames: [String], context: NSManagedObjectContext, needSave: Bool = true) {
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "SDGConnection", in: context)!

        if needSave {
            self.init(entity: entity, insertInto: context)
        } else {
            self.init(entity: entity, insertInto: nil)
        }

        self.date = date
        self.myUserName = myUsername
        self.targetUserName = targetUsername
        self.mutualUserNames = mutualUsernames
    }

//    init(myUserName: String, targetUserName: String, mutualUsers: [String] = []) {
//        super.init(entity: <#T##NSEntityDescription#>, insertIntoManagedObjectContext: <#T##NSManagedObjectContext?#>)
//
//        self.myUserName = myUserName
//        self.targetUserName = targetUserName
//        self.mutualUsers = mutualUsers
//    }

}
