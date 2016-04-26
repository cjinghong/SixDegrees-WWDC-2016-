//
//  HistoryTableViewCell.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 26/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    var connection: SDGConnection! {
        didSet {
            self.myUserIconView.user = connection.myUser
            self.targetUserIconView.user = connection.targetUser

            // Setup views
            self.dotView.layer.cornerRadius = self.dotView.frame.height/2
            self.dotView.backgroundColor = self.myUserIconView.iconBackgroundColor
            self.lineView.backgroundColor = self.myUserIconView.iconBackgroundColor
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myUserIconView: UserIconView!
    @IBOutlet weak var targetUserIconView: UserIconView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var dotHorizontalConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        // TODO: Start animating dot
        self.animateDot()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

    func animateDot() {
        let minimumScale: CGFloat = 0.5

        self.dotView.transform = CGAffineTransformMakeScale(minimumScale, minimumScale)
        self.dotHorizontalConstraint.constant = -self.lineView.frame.width/2
        self.layoutIfNeeded()

        // Go from left to center
        UIView.animateWithDuration(0.5, delay: 1, options: .CurveLinear, animations: {
            self.dotView.transform = CGAffineTransformIdentity
            self.dotHorizontalConstraint.constant = 0
            self.layoutIfNeeded()
        }) { (success: Bool) in

            // From center to right
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
                self.dotView.transform = CGAffineTransformMakeScale(minimumScale, minimumScale)
                self.dotHorizontalConstraint.constant = self.lineView.frame.width/2
                self.layoutIfNeeded()
                }, completion: { (success: Bool) in

                    // From right to center
                    UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                        self.dotView.transform = CGAffineTransformIdentity
                        self.dotHorizontalConstraint.constant = 0
                        self.layoutIfNeeded()
                    }) { (success: Bool) in

                        // From center to left
                        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
                            self.dotView.transform = CGAffineTransformMakeScale(minimumScale, minimumScale)
                            self.dotHorizontalConstraint.constant = -self.lineView.frame.width/2
                            self.layoutIfNeeded()
                            }, completion: { (success: Bool) in
                                self.animateDot()
                        })
                    }
            })
        }
    }
}
