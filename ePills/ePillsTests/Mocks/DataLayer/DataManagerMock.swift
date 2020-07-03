//
//  DataManagerMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Combine
import Foundation
import UIKit

class DataManagerMock: DataManagerProtocol {

    var addCount: Int = 0
    var removeCount: Int = 0
    var updateCount: Int = 0
    var getPrescriptionsCount: Int = 0
    var publishMedicinesCount: Int = 0
    var isEmptyCount: Int = 0
    var addDoseCount: Int = 0
    var getMedicinePictureCount: Int = 0
    var setMedicinePictureCount: Int = 0

    func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine? {
        addCount += 1
        return nil
    }

    func remove(medicine: Medicine) {
        removeCount += 1
    }

    func update(medicine: Medicine) {
        updateCount += 1
    }

    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        getPrescriptionsCount += 1
        return Just([]).eraseToAnyPublisher()
    }

    func flushMedicines() {
        publishMedicinesCount += 1
    }

    func isEmpty() -> Bool {
        isEmptyCount += 1
        return addCount == 0
    }

    func add(dose: Dose, medicine: Medicine) -> Dose? {
        addDoseCount += 1
        return nil
    }

    func getMedicinePicture(medicine: Medicine) -> Future<UIImage, DataManagerError> {
        getMedicinePictureCount += 1
        return Future<UIImage, DataManagerError> { promise in
            promise(.success(UIImage()))
        }
    }

    func setMedicinePicture(medicine: Medicine, picture: UIImage) -> Future<Bool, DataManagerError> {
        setMedicinePictureCount += 1
        return Future<Bool, DataManagerError> { promise in
            promise(.success(true))
        }
    }
}
