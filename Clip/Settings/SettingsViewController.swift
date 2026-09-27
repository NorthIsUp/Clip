//
//  SettingsViewController.swift
//  Clip
//
//  Created by Riley Testut on 6/14/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import UIKit

import ClipKit

extension SettingsViewController
{
    private enum Section: CaseIterable
    {
        case historyLimit
        case saveMode
        case location
    }
    
    static let settingsDidChangeNotification: Notification.Name = Notification.Name("SettingsDidChangeNotification")
}

class SettingsViewController: UITableViewController
{
    @IBOutlet private var showLocationIconSwitch: UISwitch!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.showLocationIconSwitch.isOn = UserDefaults.shared.showLocationIcon
    }
}

private extension SettingsViewController
{
    @IBAction func toggleShowLocationIcon(_ sender: UISwitch)
    {
        UserDefaults.shared.showLocationIcon = sender.isOn
        
        NotificationCenter.default.post(name: SettingsViewController.settingsDidChangeNotification, object: nil)
    }
}

extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        switch Section.allCases[indexPath.section]
        {
        case .historyLimit:
            let limit = HistoryLimit.allCases[indexPath.row]
            cell.accessoryType = (limit == UserDefaults.shared.historyLimit) ? .checkmark : .none
            
        case .saveMode:
            let mode = SaveMode.allCases[indexPath.row]
            cell.accessoryType = (mode == UserDefaults.shared.saveMode) ? .checkmark : .none
            
        case .location: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch Section.allCases[indexPath.section]
        {
        case .historyLimit:
            UserDefaults.shared.historyLimit = HistoryLimit.allCases[indexPath.row]
            tableView.reloadData()
            self.dismiss(animated: true, completion: nil)
            
        case .saveMode:
            UserDefaults.shared.saveMode = SaveMode.allCases[indexPath.row]
            tableView.reloadData()
            
        case .location: break
        }
    }
}
