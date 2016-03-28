//
//  ViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class LocateViewController: UIViewController {

    @IBOutlet weak var userIconEncapsulatingView: UIView!
    @IBOutlet weak var userIconView: UserIconView!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.userIconEncapsulatingView.backgroundColor = nil

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.userTapped(_:)))
        self.userIconEncapsulatingView.addGestureRecognizer(tapGesture)

        self.bounceUserIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userTapped(sender: AnyObject?) {
        showSimpleAlert("Alert", message: "You poked yourself!")
    }

    // Slowly moves the icon slightly upwards and downwards indefinately
    func bounceUserIcon(upwardsDirection: Bool = true) {
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {

            if upwardsDirection {
                self.userIconHorizontalConstraint.constant += 10
            } else {
                self.userIconHorizontalConstraint.constant -= 10
            }
            self.view.layoutIfNeeded()

        }) { (completed: Bool) in
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    if upwardsDirection {
                        self.userIconHorizontalConstraint.constant -= 10
                    } else {
                        self.userIconHorizontalConstraint.constant += 10
                    }
                    self.view.layoutIfNeeded()

                    }, completion: { (completed: Bool) in
                        self.bounceUserIcon(!upwardsDirection)
                })
        }
    }
}

// MARK: - Utils
extension UIViewController {

    func showSimpleAlert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}


