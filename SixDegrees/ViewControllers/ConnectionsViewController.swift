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

    var connectingUser: SDGUser!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userIconView.user = SDGUser.currentUser
        self.connectingUserIconView.user = self.connectingUser
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Disconnect MCsession when user tapped on the back button
        if self.isMovingFromParentViewController() {
            if let locateVC: LocateViewController = self.parentViewController as? LocateViewController {
                locateVC.bluetoothManager.session.disconnect()
            }
        }
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
