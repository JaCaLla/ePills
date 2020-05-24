//
//  MainFlowCoordinatorTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class MainFlowCoordinatorTests: XCTestCase {

    var sut: MainFlowCoordinator!
    var dataManager: DataManager  = DataManager.shared
    
    override func setUpWithError() throws {
     //  sut = MainFlowCoordinator()
          dataManager.reset()
       }

    func test_startWhenDataManagerEmpty() throws {
        // Given
        dataManager.reset()
        // When
         MainFlowCoordinator.shared.start(dataManager: dataManager)
        // Then
        guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
        if let rootViewController = window.rootViewController as? UINavigationController,
            let firstVC = rootViewController.viewControllers.first {
            XCTAssertTrue(firstVC  is FirstPrescriptionVC)
        } else {
            XCTFail()
        }
    }
    
    func test_startWhenDataManagerFilled() throws {
        // Given
        let medicine = Medicine(name: "a",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        _ = DBManager.shared.create(medicine: medicine)
        // When
         MainFlowCoordinator.shared.start(dataManager: dataManager)
        // Then
        guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
        if let rootViewController = window.rootViewController as? TabBarController {
            XCTAssertTrue(rootViewController  is  TabBarController)
        } else {
            XCTFail()
        }
    }

}
