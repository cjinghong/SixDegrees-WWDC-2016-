//
//  ConnectionsViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 20/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class ConnectionsViewController: UIViewController {

    @IBOutlet weak var connectingUserIconView: UserIconView!
    @IBOutlet weak var userIconView: UserIconView!

    var connectingUser: SDGUser! {
        didSet {
            self.connectingUserIconView.user = connectingUser
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userIconView.user = SDGUser.currentUser
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
