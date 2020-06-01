//
//  TimeManager.swift
//  ePills
//
//  Created by Javier Calatrava on 02/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

protocol TimeManagerProtocol {
    func timeIntervalSince1970() -> Int
}

final public class TimeManager {
     
   // static var shared: TimeManager = TimeManager()
    
    private var injectedDate: Date?
    
    func setInjectedDate(date: Date) {
        self.injectedDate = date
    }
}

extension TimeManager: TimeManagerProtocol {
    func timeIntervalSince1970() -> Int {
        if let uwpInjectedDate = self.injectedDate {
            return Int(uwpInjectedDate.timeIntervalSince1970)
        }
        return Int(Date().timeIntervalSince1970)
    }
}

extension TimeManager: Resetable {
    
    func reset() {
        self.injectedDate = nil
    }
}
