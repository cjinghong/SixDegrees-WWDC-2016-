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
            // Sets data
            self.myUserIconView.user = connection.myUser
            self.targetUserIconView.user = connection.targetUser

            if self.connection.mutualUsers.count == 0 {
                self.numberOfConnectionsLabel.text = ""
                self.sadIconImageView.isHidden = false
                self.mutualUserCollectionView.isHidden = true
            } else if self.connection.mutualUsers.count <= 99 {
                self.numberOfConnectionsLabel.text = "\(self.connection.mutualUsers.count)"
                self.sadIconImageView.isHidden = true
                self.mutualUserCollectionView.isHidden = false
            } else {
                self.numberOfConnectionsLabel.text = "99+"
                self.sadIconImageView.isHidden = true
                self.mutualUserCollectionView.isHidden = false
            }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, hh:mm aa"
            self.dateLabel.text = dateFormatter.string(from: connection.date as Date)

            self.mutualUserCollectionView.dataSource = self
            self.mutualUserCollectionView.delegate = self
            self.mutualUserCollectionView.reloadSections(IndexSet(integer: 0))

            // UI Stuff
            // Drop shadow on number of connections
            self.numberOfConnectionsLabel.layer.shadowOpacity = 1
            self.numberOfConnectionsLabel.layer.shadowRadius = 0
            self.numberOfConnectionsLabel.layer.shadowColor = UIColor.black.cgColor
            self.numberOfConnectionsLabel.layer.shadowOffset = CGSize(width: -1, height: 1)

            // Make sad icon white
            self.sadIconImageView.image = self.sadIconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            self.sadIconImageView.tintColor = UIColor.white

            // Bring the 2 views infront. 
            // For some reason the dot view managed to go above them
            self.myUserIconView.layer.zPosition = 100
            self.targetUserIconView.layer.zPosition = 100

            // Setup views
            self.dotView.layer.cornerRadius = self.dotView.frame.height/2
            self.dotView.backgroundColor = self.myUserIconView.iconBackgroundColor
            self.lineView.backgroundColor = self.myUserIconView.iconBackgroundColor
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var numberOfConnectionsLabel: UILabel!
    @IBOutlet weak var sadIconImageView: UIImageView!
    @IBOutlet weak var myUserIconView: UserIconView!
    @IBOutlet weak var targetUserIconView: UserIconView!
    @IBOutlet weak var mutualUserCollectionView: UICollectionView!

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var dotHorizontalConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        // TODO: Start animating dot
        self.animateDot()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func animateDot() {
        let minimumScale: CGFloat = 0.5

        self.dotView.transform = CGAffineTransform(scaleX: minimumScale, y: minimumScale)
        self.dotHorizontalConstraint.constant = -self.lineView.frame.width/2
        self.layoutIfNeeded()

        // Go from left to center
        UIView.animate(withDuration: 0.5, delay: 1, options: [.curveLinear, .allowUserInteraction], animations: {
            self.dotView.transform = CGAffineTransform.identity
            self.dotHorizontalConstraint.constant = 0

            // Change to a color in between
            self.lineView.backgroundColor = UIColor.midColor(self.myUserIconView.iconBackgroundColor, colorB: self.targetUserIconView.iconBackgroundColor)
            self.dotView.backgroundColor = UIColor.midColor(self.myUserIconView.iconBackgroundColor, colorB: self.targetUserIconView.iconBackgroundColor)

            self.layoutIfNeeded()
        }) { (success: Bool) in

            // From center to right
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.dotView.transform = CGAffineTransform(scaleX: minimumScale, y: minimumScale)
                self.dotHorizontalConstraint.constant = self.lineView.frame.width/2

                self.lineView.backgroundColor = self.targetUserIconView.iconBackgroundColor
                self.dotView.backgroundColor = self.targetUserIconView.iconBackgroundColor

                self.layoutIfNeeded()
                }, completion: { (success: Bool) in

                    // From right to center
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
                        self.dotView.transform = CGAffineTransform.identity
                        self.dotHorizontalConstraint.constant = 0

                        // Change to a color in between
                        self.lineView.backgroundColor = UIColor.midColor(self.myUserIconView.iconBackgroundColor, colorB: self.targetUserIconView.iconBackgroundColor)
                        self.dotView.backgroundColor = UIColor.midColor(self.myUserIconView.iconBackgroundColor, colorB: self.targetUserIconView.iconBackgroundColor)

                        self.layoutIfNeeded()
                    }) { (success: Bool) in

                        // From center to left
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                            self.dotView.transform = CGAffineTransform(scaleX: minimumScale, y: minimumScale)
                            self.dotHorizontalConstraint.constant = -self.lineView.frame.width/2

                            // Change to a color in between
                            self.lineView.backgroundColor = self.myUserIconView.iconBackgroundColor
                            self.dotView.backgroundColor = self.myUserIconView.iconBackgroundColor

                            self.layoutIfNeeded()
                            }, completion: { (success: Bool) in
                                self.animateDot()
                        })
                    }
            })
        }
    }
}

extension HistoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.connection.mutualUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.user = self.connection.mutualUsers[indexPath.row]
        return cell
    }
}




