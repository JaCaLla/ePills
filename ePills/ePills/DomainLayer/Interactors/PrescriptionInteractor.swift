//
//  PrescriptionInteractor.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
protocol PrescriptionInteractorProtocol {
    func getPrecriptionInterval() -> [Interval]
}


final class PrescriptionInteractor {
    
}

// MARK: - PrescriptionInteractorProtocol
extension PrescriptionInteractor: PrescriptionInteractorProtocol {
    func getPrecriptionInterval() -> [Interval] {
        return []
    }
}
