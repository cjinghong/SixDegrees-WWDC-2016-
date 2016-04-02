//
//  LoginViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 01/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    var facebookLoginButton: FBSDKLoginButton!

    var userDidLoginBlock: ((token: FBSDKAccessToken) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adds facebook login button
        let fbLoginButton: FBSDKLoginButton = FBSDKLoginButton()
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 50
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        self.facebookLoginButton = fbLoginButton
        self.view.addSubview(fbLoginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // For using a custom UIButton for facebook login
    func loginButtonTapped(sender: AnyObject?) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (loginResult: FBSDKLoginManagerLoginResult!, error: NSError!) in

            if error != nil {
                print("\(error.localizedDescription)")
            } else if loginResult.isCancelled {
                print("User cancelled results")
            } else {
                print("\(loginResult.description)")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - FB Login button delegate
extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        // When user logs in

        if result.token != nil {
//            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // What happens when user logs out
    }
}