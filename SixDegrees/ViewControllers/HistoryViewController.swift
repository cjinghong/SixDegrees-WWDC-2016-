//
//  HistoryViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 26/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit
import CoreData
import Contacts

class HistoryViewController: UIViewController {
    var displayMode: SDGDisplayMode! {
        didSet {
            if displayMode == SDGDisplayMode.simulated {
                self.historyTableView.tableHeaderView?.frame.size.height = 20
            } else {
                self.historyTableView.tableHeaderView?.frame.size.height = 0
            }
        }
    }

    let MOC: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    var expandIndex: Int?
    var connections: [SDGConnection] = [] {
        didSet {
            self.connections.sort { (aConnection: SDGConnection, bConnection: SDGConnection) -> Bool in
                return aConnection.date.compare(bConnection.date as Date) == ComparisonResult.orderedDescending
            }
            self.historyTableView.reloadData()
        }
    }
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var placeholderImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set display mode
        let userDefaults: UserDefaults = UserDefaults.standard
        let simulationEnabled: Bool = userDefaults.bool(forKey: SDGSimulationEnabled)
        if simulationEnabled {
            self.displayMode = SDGDisplayMode.simulated
        } else {
            self.displayMode = SDGDisplayMode.normal
        }
        // Setup table
        self.historyTableView.separatorStyle = .none

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

        // Make placeholder white
        self.placeholderImageView.image = self.placeholderImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.placeholderImageView.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.view.bringSubview(toFront: self.historyTableView)

        // Show/hide simulation enabled label
        let userDefaults: UserDefaults = UserDefaults.standard
        let simulationEnabled: Bool = userDefaults.bool(forKey: SDGSimulationEnabled)

        if simulationEnabled {
            // If display mode is not already simulated, simulate.
            if self.displayMode != SDGDisplayMode.simulated {
                self.displayMode = SDGDisplayMode.simulated
            }
            // Give simulated data
            self.createSimulatedConnections()

        } else {
            // If display mode is not already normal, make it normal.
            if self.displayMode != SDGDisplayMode.normal {
                self.displayMode = SDGDisplayMode.normal
            }
            self.fetchConnectionsFromCoreData()
        }
    }
    
    func fetchConnectionsFromCoreData() {
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SDGConnection")

        do {
            if let results: [SDGConnection] = try (self.MOC.fetch(fetchRequest)) as? [SDGConnection] {
                self.connections = results
            }
        } catch {
            print("Error retrieving history")
        }
    }

    func createSimulatedConnections() {
        let connection: SDGConnection = SDGConnection(date: Date(), myUsername: SDGUser.simulatedCurrentUser.name, targetUsername: SDGUser.simulatedDiscoveredUser.name, mutualUsernames: SDGUser.simulatedUsernames(), context: self.MOC, needSave: false)
        self.connections = [connection]
    }

    func historyCellTapped(_ sender: UIGestureRecognizer?) {

        if let tag = sender?.view?.tag {
            if tag == self.expandIndex {
                self.expandIndex = nil
            } else {
                self.expandIndex = tag
            }

            self.historyTableView.beginUpdates()
            self.historyTableView.endUpdates()
            self.historyTableView.scrollToRow(at: IndexPath(row: tag, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        }
    }

}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.connections.count == 0 {
            self.historyTableView.isHidden = true
        } else {
            self.historyTableView.isHidden = false
        }
        return self.connections.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.expandIndex {
            return 220
        } else {
            return 135
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCell: HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        historyCell.selectionStyle = .none
        historyCell.connection = self.connections[indexPath.row]

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.historyCellTapped(_:)))
        historyCell.tag = indexPath.row
        historyCell.addGestureRecognizer(tapGesture)

        return historyCell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connections"
    }
}





