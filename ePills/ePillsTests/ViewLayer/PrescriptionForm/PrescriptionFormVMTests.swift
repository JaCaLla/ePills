//
//  PrescriptionFormVMTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

@testable import ePills
import XCTest

class PrescriptionFormVMTests: XCTestCase {
    
    var sut:PrescriptionFormVM!
    let dataManagerMock: DataManagerMock = DataManagerMock()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.sut = PrescriptionFormVM(dataManager: dataManagerMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addPrescription() throws {
        sut.save()
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }
    
    func test_getIntervals_es() throws {
        Bundle.setLanguage(lang: "es")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 8 else {
            XCTFail()
            return
        }
        XCTAssertEqual(intervals[0].hours, 1)
        XCTAssertEqual(intervals[0].label, "1 Hora")
        XCTAssertEqual(intervals[1].hours, 2)
        XCTAssertEqual(intervals[1].label, "2 Horas")
        XCTAssertEqual(intervals[2].hours, 4)
        XCTAssertEqual(intervals[2].label, "4 Horas")
        XCTAssertEqual(intervals[3].hours, 6)
        XCTAssertEqual(intervals[3].label, "6 Horas")
        XCTAssertEqual(intervals[4].hours, 8)
        XCTAssertEqual(intervals[4].label, "8 Horas")
        XCTAssertEqual(intervals[5].hours, 12)
        XCTAssertEqual(intervals[5].label, "12 Horas")
        XCTAssertEqual(intervals[6].hours, 16)
        XCTAssertEqual(intervals[6].label, "16 Horas")
        XCTAssertEqual(intervals[7].hours, 1)
        XCTAssertEqual(intervals[7].label, "1 Día")
    }
    
    func test_getIntervals_en() throws {
        // Update the language by swaping bundle
        Bundle.setLanguage(lang: "en")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 8 else {
            XCTFail()
            return
        }
        XCTAssertEqual(intervals[0].hours, 1)
        XCTAssertEqual(intervals[0].label, "1 Hour")
        XCTAssertEqual(intervals[1].hours, 2)
        XCTAssertEqual(intervals[1].label, "2 Hours")
        XCTAssertEqual(intervals[2].hours, 4)
        XCTAssertEqual(intervals[2].label, "4 Hours")
        XCTAssertEqual(intervals[3].hours, 6)
        XCTAssertEqual(intervals[3].label, "6 Hours")
        XCTAssertEqual(intervals[4].hours, 8)
        XCTAssertEqual(intervals[4].label, "8 Hours")
        XCTAssertEqual(intervals[5].hours, 12)
        XCTAssertEqual(intervals[5].label, "12 Hours")
        XCTAssertEqual(intervals[6].hours, 16)
        XCTAssertEqual(intervals[6].label, "16 Hours")
        XCTAssertEqual(intervals[7].hours, 1)
        XCTAssertEqual(intervals[7].label, "1 Day")
    }
}
