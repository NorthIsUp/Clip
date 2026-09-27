//
//  UserDefaults+App.swift
//  Clip
//
//  Created by Riley Testut on 6/14/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import Foundation

import Roxas

@objc public enum HistoryLimit: Int, CaseIterable
{
    case _10 = 10
    case _25 = 25
    case _50 = 50
    case _100 = 100
}

@objc public enum SaveMode: Int, CaseIterable
{
    case notification = 0
    case automatic = 1
}

public extension UserDefaults
{
    static let shared: UserDefaults = {
        guard let appGroup = Bundle.main.appGroups.first else { return .standard }
        
        let sharedUserDefaults = UserDefaults(suiteName: appGroup)!
        return sharedUserDefaults
    }()
    
    @NSManaged var historyLimit: HistoryLimit
    @NSManaged var maximumClippingSize: Int
    @NSManaged var showLocationIcon: Bool
    @NSManaged var saveMode: SaveMode
}

public extension UserDefaults
{
    func registerAppDefaults()
    {
        self.register(defaults: [
            #keyPath(UserDefaults.historyLimit): HistoryLimit._25.rawValue,
            #keyPath(UserDefaults.maximumClippingSize): 10 * .bytesPerMegabyte,
            #keyPath(UserDefaults.showLocationIcon): true,
            #keyPath(UserDefaults.saveMode): SaveMode.automatic.rawValue
        ])
    }
}
