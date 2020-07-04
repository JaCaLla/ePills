//
//  UTConfigurationManager.swift
//  iMug
//
//  Copyright © 2017 Nestlé S.A. All rights reserved.
//

import XCTest
@testable import ePills
class UTConfigurationManager: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ConfigurationManager.shared.reset()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - Version
    func test_setLastExecutedVersion() {

        ConfigurationManager.shared.setLastExecutedToBundleVersion()

        XCTAssertEqual(ConfigurationManager.shared.getAppVersion(), "3.0.0")
    }

    func test_getLastExecutedVersion () {

        if let _ = ConfigurationManager.shared.getLastExecutedVersion() {
            XCTFail("\(#function)")
        }

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), true)

        ConfigurationManager.shared.setLastExecutedToBundleVersion()

        if let version = ConfigurationManager.shared.getLastExecutedVersion() {
            XCTAssertEqual(version, "3.0.0")
        }
    }

    func test_isFirstTimeInLifeAppExecution() {

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), true)

        ConfigurationManager.shared.setLastExecutedToBundleVersion()

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), false)

    }

    func test_isFirstTimeAfterSoftwareUpdateExecution() {

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeAfterSoftwareUpdateExecution(), true)
        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), true)

        ConfigurationManager.shared.setLastExecutedToBundleVersion()

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeAfterSoftwareUpdateExecution(), false)
        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), false)

        UserDefaults.standard.set("0.8.0", forKey: ConfigurationManager.UserDefaultsKeys.version)
        UserDefaults.standard.synchronize()

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeAfterSoftwareUpdateExecution(), false)
        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), false)

        UserDefaults.standard.set("4.0.0", forKey: ConfigurationManager.UserDefaultsKeys.version)
        UserDefaults.standard.synchronize()

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeAfterSoftwareUpdateExecution(), true)
        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), false)

        UserDefaults.standard.set("4.0.0", forKey: ConfigurationManager.UserDefaultsKeys.version)
        UserDefaults.standard.synchronize()

        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeAfterSoftwareUpdateExecution(), true)
        XCTAssertEqual(ConfigurationManager.shared.isFirstTimeInLifeAppExecution(), false)

    }
}
