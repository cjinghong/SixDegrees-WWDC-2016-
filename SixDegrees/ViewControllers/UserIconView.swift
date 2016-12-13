//
//  UserIconView.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class UserIconView: UIView {

    @IBInspectable
    var iconBackgroundColor: UIColor = UIColor.clear {
        didSet {
            self.iconImageView.backgroundColor = iconBackgroundColor
        }
    }
    var nameLabel: UILabel!
    var iconImageView: UIImageView!

    var user: SDGUser? {
        didSet {
            self.nameLabel.text = user?.name
            self.iconBackgroundColor = user?.color ?? UIColor.clear
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.clipsToBounds = false
        self.backgroundColor = nil

        // Add label
        let nameLabel: UILabel = UILabel(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 20))
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 2
        self.addSubview(nameLabel)
        self.nameLabel = nameLabel

        // Add icon
        // Image frame is in the center aligned to superview
        let imageFrame: CGRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let iconImageView: UIImageView = UIImageView(frame: imageFrame)
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = UIViewContentMode.scaleAspectFit
        iconImageView.backgroundColor = self.iconBackgroundColor
        iconImageView.image = UIImage(named: "user")
        iconImageView.layer.cornerRadius = self.frame.height/2
        self.addSubview(iconImageView)
        self.iconImageView = iconImageView
    }
}
