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
        self.speechBubbleView?.isHidden = true
    }

    func showDetails() {
        self.speechBubbleView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.speechBubbleView?.isHidden = false

        if let identifierLabel = self.identifierLabel {
            identifierLabel.text = self.user?.identifier ?? "Hi, I'm \(self.user!.name!)"
            self.speechBubbleView!.bringSubview(toFront: identifierLabel)
        }


        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.speechBubbleView?.transform = CGAffineTransform.identity
            }, completion: {(success: Bool) in
        })

        self.detailsShowing = true
    }

    func hideDetails() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.speechBubbleView?.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.layoutIfNeeded()
            
            }, completion: {(success: Bool) in
                self.speechBubbleView?.isHidden = true
        })
        
        self.detailsShowing = false
    }
}
