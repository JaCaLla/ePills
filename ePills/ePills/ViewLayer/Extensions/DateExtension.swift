//
//  DateExtension.swift
//  ePills
//
//  Created by Javier Calatrava on 10/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

extension Date {
    // This method cannot be consolidated into the Date extension, because
    // it cannot be compiled into VLGNextFlightWidget target
    func format(_ format: String) -> String {
        /// return VLVuelingUtils.string(from: self, format: format)

        let dateformat = DateFormatter()
        dateformat.timeZone = TimeZone(abbreviation: "UTC")
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.calendar = Calendar(identifier: .gregorian)
        dateformat.dateFormat = format
        return dateformat.string(from: self)

    }

    func isToday() -> Bool {
        let today = Date().dateFormatUTC()
        let otherDate = self.dateFormatUTC()
        if today == otherDate {
            print("now")
        }
        return today == otherDate
    }

    func isSameDDMMYYYY(date: Date) -> Bool {
        let calendar = Calendar.current
        let componentsDate = calendar.dateComponents([.year, .month, .day], from: date)
        let componentsSelf = calendar.dateComponents([.year, .month, .day], from: self)

        return componentsDate.day == componentsSelf.day &&
            componentsDate.month == componentsSelf.month &&
            componentsDate.year == componentsSelf.year
    }
    
    func getDateFor(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
}
