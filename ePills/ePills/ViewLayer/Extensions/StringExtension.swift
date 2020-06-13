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

    func localized(_ args: [CVarArg]) -> String {
        return localized(args)
    }

    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, args)
    }

    func toDate(format: String) -> Date? {
        let dateformat = DateFormatter()
        // dateformat.timeZone = TimeZone(abbreviation: "UTC")
        // dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.calendar = Calendar(identifier: .gregorian)
        dateformat.dateFormat = format
        return dateformat.date(from: self)
    }
}
