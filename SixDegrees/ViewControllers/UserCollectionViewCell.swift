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

    @IBOutlet weak var speechBubbleView: UIView?
    @IBOutlet weak var identifierLabel: UILabel?
    @IBOutlet weak var userIconView: UserIconView!

    var detailsShowing: Bool = false

    override func awakeFromNib() {
        self.speechBubbleView?.hidden = true
    }

    func showDetails() {
        self.speechBubbleView?.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.speechBubbleView?.hidden = false

        if let identifierLabel = self.identifierLabel {
            identifierLabel.text = self.user?.identifier ?? "Hi, I'm \(self.user!.name!)"
            self.speechBubbleView!.bringSubviewToFront(identifierLabel)
        }


        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.speechBubbleView?.transform = CGAffineTransformIdentity
            }, completion: {(success: Bool) in
        })

        self.detailsShowing = true
    }

    func hideDetails() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.speechBubbleView?.transform = CGAffineTransformMakeScale(0, 0)
            self.layoutIfNeeded()
            
            }, completion: {(success: Bool) in
                self.speechBubbleView?.hidden = true
        })
        
        self.detailsShowing = false
    }
}
