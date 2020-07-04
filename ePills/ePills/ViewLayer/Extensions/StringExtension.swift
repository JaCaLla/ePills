//
//  StringExtension.swift
//  vlng
//
//  Created by Javier Calatrava Llaveria on 21/05/2019.
//  Copyright © 2019 Javier Calatrava Llaveria. All rights reserved.
//

import Foundation
import UIKit

extension String {

    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }

    func toDate(format: String) -> Date? {
        let dateformat = DateFormatter()
        // dateformat.timeZone = TimeZone(abbreviation: "UTC")
        // dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.calendar = Calendar(identifier: .gregorian)
        dateformat.dateFormat = format
        return dateformat.date(from: self)
    }
    
    func randomString(length: Int) -> String {

        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
}
