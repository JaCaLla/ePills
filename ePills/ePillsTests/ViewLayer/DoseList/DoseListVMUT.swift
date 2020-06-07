//
//  DoseListVMUT.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 03/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class DoseListVMUT: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getDosesWhenBiCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let medicine = Medicine(name: "aaa", unitsBox: 2, intervalSecs: 3600, unitsDose: 1)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 + 300))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600, timeManager: timeManager))
        medicine.currentCycle.unitsConsumed = 2
        let sut = DoseListVM(medicine: medicine)
        let doseCellViewModels = sut.getDoses()
        guard doseCellViewModels.count == 2 else { XCTFail(); return }
        var doseCellViewModel = doseCellViewModels[0]
        XCTAssertEqual(doseCellViewModel.doseOrder, "1/2")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 01:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "00s")
        XCTAssertEqual(doseCellViewModel.doseCellType, .endToday)

        doseCellViewModel = doseCellViewModels[1]
        XCTAssertEqual(doseCellViewModel.doseOrder, "2/2")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 02:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "-5m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .startPast)

    }
    
    func test_monoCycle() {
        
        let medicine = Medicine(name: "aaa", unitsBox: 1, intervalSecs: 3600, unitsDose: 1)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800, timeManager: timeManager))

        let sut = DoseListVM(medicine: medicine)
        medicine.currentCycle.unitsConsumed = 1
        let doseCellViewModels = sut.getDoses()
        guard doseCellViewModels.count == 1 else { XCTFail(); return }
        let doseCellViewModel = doseCellViewModels[0]
        XCTAssertEqual(doseCellViewModel.doseOrder, "1/1")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 01:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "00s")
        XCTAssertEqual(doseCellViewModel.doseCellType, .monoCycle)
        
        /*
         
         // Monocyle
         // return  [DoseCellViewModel(day: "1", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .monoCycle, isFirst: true)]
          
         
         */
    }
    
    func test_cycleFinished() {
        let medicine = Medicine(name: "aaa", unitsBox: 5, intervalSecs: 3600, unitsDose: 1)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 + 300))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 2 + 600))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 2, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 3 - 300))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 3, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 4 - 600))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 4, timeManager: timeManager))
        medicine.currentCycle.unitsConsumed = 5
        let sut = DoseListVM(medicine: medicine)
        let doseCellViewModels = sut.getDoses()
        guard doseCellViewModels.count == 5 else { XCTFail(); return }
        var doseCellViewModel = doseCellViewModels[0]
        XCTAssertEqual(doseCellViewModel.doseOrder, "1/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 01:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "00s")
        XCTAssertEqual(doseCellViewModel.doseCellType, .endPast)

        doseCellViewModel = doseCellViewModels[1]
        XCTAssertEqual(doseCellViewModel.doseOrder, "2/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 02:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "-5m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .middle)
        
        doseCellViewModel = doseCellViewModels[2]
        XCTAssertEqual(doseCellViewModel.doseOrder, "3/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 03:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "-10m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .middle)
        
        doseCellViewModel = doseCellViewModels[3]
        XCTAssertEqual(doseCellViewModel.doseOrder, "4/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 04:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "05m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .middle)
        
        doseCellViewModel = doseCellViewModels[4]
        XCTAssertEqual(doseCellViewModel.doseOrder, "5/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 05:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "10m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .startPast)
        
    }
    
    func test_cycleNotFinished() {
        let medicine = Medicine(name: "aaa", unitsBox: 5, intervalSecs: 3600, unitsDose: 1)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 + 300))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 2 + 600))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 2, timeManager: timeManager))
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 3 - 300))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 3, timeManager: timeManager))
//        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 4 - 600))
//        medicine.currentCycle.doses.append(Dose(expected: 1583020800 + 3600 * 4, timeManager: timeManager))
        medicine.currentCycle.unitsConsumed = 4
        let sut = DoseListVM(medicine: medicine)
        let doseCellViewModels = sut.getDoses()
        guard doseCellViewModels.count == 4 else { XCTFail(); return }
        var doseCellViewModel = doseCellViewModels[0]
        XCTAssertEqual(doseCellViewModel.doseOrder, "1/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 01:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "00s")
        XCTAssertEqual(doseCellViewModel.doseCellType, .endToday)

        doseCellViewModel = doseCellViewModels[1]
        XCTAssertEqual(doseCellViewModel.doseOrder, "2/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 02:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "-5m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .middle)
        
        doseCellViewModel = doseCellViewModels[2]
        XCTAssertEqual(doseCellViewModel.doseOrder, "3/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 03:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "-10m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .middle)
        
        doseCellViewModel = doseCellViewModels[3]
        XCTAssertEqual(doseCellViewModel.doseOrder, "4/5")
        XCTAssertEqual(doseCellViewModel.day, "1")
        XCTAssertEqual(doseCellViewModel.monthYear, "March - 2020")
        XCTAssertEqual(doseCellViewModel.weekdayHHMM, "Sunday - 04:00")
        XCTAssertEqual(doseCellViewModel.realOffset, "05m")
        XCTAssertEqual(doseCellViewModel.doseCellType, .startPast)

    }
}
