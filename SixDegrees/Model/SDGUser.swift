//
//  User.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 02/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import Foundation
import SwiftyJSON

class SDGUser {

    enum Gender: String {
        case Male = "male"
        case Female = "female"
    }

    var id: String!
    var name: String!
    var gender: Gender!

    init(name: String, id: String, gender: String) {
        self.name = name
        self.id = id
        self.gender = Gender(rawValue: gender)!
    }

    init?(json: JSON) {
        self.id = json["id"].string!
        self.name = json["name"].string!
        self.gender = Gender(rawValue: json["gender"].string!)!

        if self.id == nil || self.name == nil || self.gender == nil {
            return nil
        }
    }

}