//
//  SimulationTableViewCell.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 28/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

let SDGSimulationEnabled: String = "SDGSimulationEnabled"

class SimulationTableViewCell: UITableViewCell {

    @IBOutlet weak var simulationSwitch: UISwitch!

    let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.simulationSwitch.on = self.userDefaults.boolForKey(SDGSimulationEnabled)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func simulationSwitchChanged(sender: AnyObject) {
        // Save to user defaults
        self.userDefaults.setBool(sender.on, forKey: SDGSimulationEnabled)
        self.userDefaults.synchronize()
    }
}
