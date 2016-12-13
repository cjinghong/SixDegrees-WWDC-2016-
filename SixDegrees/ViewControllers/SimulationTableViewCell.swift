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

    let userDefaults: UserDefaults = UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.simulationSwitch.isOn = self.userDefaults.bool(forKey: SDGSimulationEnabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func simulationSwitchChanged(_ sender: AnyObject) {
        // Save to user defaults
        self.userDefaults.set(sender.isOn, forKey: SDGSimulationEnabled)
        self.userDefaults.synchronize()
    }
}
