//
//  UserCollectionViewCell.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 16/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {

    var user: SDGUser? {
        didSet {
            self.userIconView.user = self.user
        }
    }

    @IBOutlet weak var userIconView: UserIconView!
}
