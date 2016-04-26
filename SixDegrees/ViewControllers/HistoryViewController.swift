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

    var expandIndexPath: NSIndexPath?
    var connections: [SDGConnection] = []
    @IBOutlet weak var historyTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        let connection1: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
//        connection1.myUserName = "Chan Jing Hong"
//        connection1.targetUserName = "Hong Jing Chan"
//        connection1.mutualUserNames = []
//
//        let connection2: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
//        connection2.myUserName = "Chan Jing Hong"
//        connection2.targetUserName = "Hong Jing Chan"
//        connection2.mutualUserNames = []
//
//        let connection3: SDGConnection = NSEntityDescription.insertNewObjectForEntityForName("SDGConnection", inManagedObjectContext: MOC) as! SDGConnection
//        connection3.myUserName = "Chan Jing Hong"
//        connection3.targetUserName = "Hong Jing Chan"
//        connection3.mutualUserNames = []
//
//        self.connections = [connection1, connection2, connection3]

        // Setup table
        self.historyTableView.separatorStyle = .None

        // TODO: Only use this next time
        self.fetchConnectionsFromCoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        self.fetchConnectionsFromCoreData()
    }
    
    func fetchConnectionsFromCoreData() {
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SDGConnection")

        do {
            if let results: [SDGConnection] = try (self.MOC.executeFetchRequest(fetchRequest)) as? [SDGConnection] {
                self.connections = results
                self.historyTableView.reloadData()
            }
        } catch {
            print("Error retrieving history")
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

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.connections.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == self.expandIndexPath {
            return 350
        } else {
            return 135
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let historyCell: HistoryTableViewCell = tableView.dequeueReusableCellWithIdentifier("HistoryTableViewCell", forIndexPath: indexPath) as! HistoryTableViewCell
        historyCell.connection = self.connections[indexPath.row]
        historyCell.selectionStyle = .None

        return historyCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath == self.expandIndexPath {
            self.expandIndexPath = nil
        } else {
            self.expandIndexPath = indexPath
        }

        tableView.beginUpdates()
        tableView.endUpdates()

        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)

//        // TODO: Actually show the mutual friends
//        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [.CurveEaseOut, .AllowUserInteraction], animations: {
//            tableView.cellForRowAtIndexPath(indexPath)?.frame.size.height = 200
//            }, completion: nil)

    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connections"
    }
}