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

        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: Bundle.localizedBundle(),
                                 value: "",
                                 comment: "")
    }
}
