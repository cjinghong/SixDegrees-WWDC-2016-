//
//  ViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/03/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKCoreKit

class LocateViewController: UIViewController {

    @IBOutlet weak var userIconEncapsulatingView: UIView!
    @IBOutlet weak var userIconView: UserIconView!
    var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var userIconHorizontalConstraint: NSLayoutConstraint!

    var token: FBSDKAccessToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        // User icon view
        self.userIconEncapsulatingView.backgroundColor = nil
//        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.userTapped(_:)))
//        self.userIconEncapsulatingView.addGestureRecognizer(tapGesture)
//        self.bounceUserIcon()
    }

    override func viewDidAppear(animated: Bool) {
        // If user is not logged in, makes sure they do.
        if let token = FBSDKAccessToken.currentAccessToken() {
            self.token = token
        } else {
            let loginVC: LoginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            loginVC.userDidLoginBlock = {(token: FBSDKAccessToken) -> Void in
                self.token = token
            }
            self.presentViewController(loginVC, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func userTapped(sender: AnyObject?) {
        showSimpleAlert("Alert", message: "Yo")
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


