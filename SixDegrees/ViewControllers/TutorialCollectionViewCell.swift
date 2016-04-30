//
//  TutorialCollectionViewCell.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 29/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class TutorialCollectionViewCell: UICollectionViewCell {

    var maximumIndex: Int!
    var index: Int! {
        didSet {
            switch index {
            case 0:
                self.instructionLabel.text = "Searching for nearby users. Make sure the device's wifi is on. You don't have to be connected to the internet for this to work."
            case 1:
                self.instructionLabel.text = "Available users will be shown on the screen"
            case 2:
                self.instructionLabel.text = "Tap on the user you would like to connect with"
            case 3:
                self.instructionLabel.text = "Six Degrees will attempt to find common connections based on your address book"
            case 4:
                self.instructionLabel.text = "If there are common connections, the names will be displayed on screen"
            case 5:
                self.instructionLabel.text = "View the number of connections that you and your friend have in common with in History screen"
            case 6:
                self.instructionLabel.text = "Tapping on a cell would display the common connections that you have."
            default:
                self.instructionLabel.text = ""
            }
        }
    }
    var tutorialImage: UIImage! {
        didSet {
            self.tutorialImageView.image = self.tutorialImage
        }
    }

    @IBOutlet weak var tutorialImageView: UIImageView!
    @IBOutlet weak var greyView: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!

    override func awakeFromNib() {
        self.greyView.alpha = 0
        self.greyView.backgroundColor = UIColor.blackColor()

        self.instructionLabel.alpha = 0
        self.doneButton.hidden = true
    }

    func showInstructions() {
        self.greyView.alpha = 0
        self.instructionLabel.alpha = 0

        UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction], animations: {
            self.greyView.alpha = 0.7
            }, completion: {(success: Bool) in
        })

        UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction], animations: { 
            self.instructionLabel.alpha = 1
        }) { (success: Bool) in

        }

        // Show button if its the last screen
        if self.index == self.maximumIndex-1 {
            self.doneButton.alpha = 0
            self.doneButton.hidden = false

            UIView.animateWithDuration(1, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: { 
                self.doneButton.alpha = 1
                }, completion: nil)
        } else {
            self.doneButton.hidden = true
        }

    }

}
