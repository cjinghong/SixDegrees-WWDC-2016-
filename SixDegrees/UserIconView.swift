//
//  UserIconView.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class UserIconView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable
    var iconBackgroundColor: UIColor = UIColor.clearColor() {
        didSet {
            self.iconImageView.backgroundColor = iconBackgroundColor
        }
    }

    var nameLabel: UILabel!
    var iconImageView: UIImageView!

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
        let nameLabel: UILabel = UILabel(frame: CGRect(x: -((100-self.frame.width)/2), y: -20, width: 100, height: 20))
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.font = UIFont.systemFontOfSize(14)
        nameLabel.adjustsFontSizeToFitWidth = true
        // TODO: This shouldn't be hardcoded
        nameLabel.text = "Me"
        self.addSubview(nameLabel)
        self.nameLabel = nameLabel

        // Add icon
        // Image frame is in the center aligned to superview, and
        let imageFrame: CGRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-0)
        let iconImageView: UIImageView = UIImageView(frame: imageFrame)
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
        iconImageView.backgroundColor = self.iconBackgroundColor
        iconImageView.image = UIImage(named: "gender_neutral_user_filled")
        iconImageView.layer.cornerRadius = self.frame.height/2
        self.addSubview(iconImageView)
        self.iconImageView = iconImageView

    }
}
