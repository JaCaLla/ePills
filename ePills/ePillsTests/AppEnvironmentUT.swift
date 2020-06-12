//
//  AppEnvironmentUT.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 11/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class AppEnvironmentUT: XCTestCase {

    func test_toString() {
        XCTAssertEqual(Environment.debug.toString, "dev")
        XCTAssertEqual(Environment.production.toString, "production")
    }

    func test_firebaseConfigFilename() {
        XCTAssertEqual(Environment.debug.firebaseConfigFilename, "GoogleService-Info-Debug")
        XCTAssertEqual(Environment.production.firebaseConfigFilename, "GoogleService-Info-Prod")
    }
}
