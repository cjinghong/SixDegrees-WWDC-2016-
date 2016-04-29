//
//  SettingsViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var cellIdentifiers: [String] = [
        "tutorialCell",
        "simulationCell"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = nil
        self.tableView.backgroundView?.backgroundColor = nil
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellIdentifiers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifiers[indexPath.row])!
        if self.cellIdentifiers[indexPath.row] == "simulationCell" {
            cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifiers[indexPath.row]) as! SimulationTableViewCell
            cell.selectionStyle = .None
        }
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.cellIdentifiers[indexPath.row] == "simulationCell" {
            return self.simulationCellHeight()
        }
        return 70
    }

    func simulationCellHeight() -> CGFloat {
        let text: String = "Turning simulation on allows you experience the app without any real users. All users and connections made with simulation turned on are not real."
        let boundingRect: CGRect! = (text as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - 8 - 8, 9999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)], context: nil)
        let height: CGFloat = 17 + 36 + 8 + boundingRect.size.height + 17
        return height
    }
}