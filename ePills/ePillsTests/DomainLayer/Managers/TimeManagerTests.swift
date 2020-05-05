//
//  TimeManagerTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 02/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class TimeManagerTests: XCTestCase {

    var sut: TimeManager!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = TimeManager()
        sut.reset()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_injectedDate() throws {
 
        let date = Date(timeIntervalSince1970: 1480134638)
        sut.setInjectedDate(date: date)
        XCTAssertEqual(sut.timeIntervalSince1970(), 1480134638)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func test_timeIntervalSince1970() {
        let expected = Int(Date().timeIntervalSince1970)
        let received = sut.timeIntervalSince1970()
        XCTAssertEqual(expected, received)
    }

}
