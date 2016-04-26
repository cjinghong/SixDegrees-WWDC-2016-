//
//  HistoryViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 26/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    let MOC: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var connections: [SDGConnection] = []
    @IBOutlet weak var historyTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let connection1: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
        connection1.myUserName = "Chan Jing Hong"
        connection1.targetUserName = "Hong Jing Chan"
        connection1.mutualUserNames = []

        let connection2: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
        connection2.myUserName = "Chan Jing Hong"
        connection2.targetUserName = "Hong Jing Chan"
        connection2.mutualUserNames = []

        let connection3: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
        connection3.myUserName = "Chan Jing Hong"
        connection3.targetUserName = "Hong Jing Chan"
        connection3.mutualUserNames = []

        self.connections = [connection1, connection2, connection3]

        // Setup table
        self.historyTableView.separatorStyle = .None
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

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connections.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 135
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let historyCell: HistoryTableViewCell = tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath) as! HistoryTableViewCell
        historyCell.connection = self.connections[indexPath.row]
        return historyCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}