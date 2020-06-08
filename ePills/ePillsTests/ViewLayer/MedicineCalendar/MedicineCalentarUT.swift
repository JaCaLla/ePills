//
//  MedicineCalentarUT.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 28/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class MedicineCalentarUT: XCTestCase {

    var sut: MedicineCalendarVM!
    //  var homeCoordintorMock: HomeCoordinatorMock!
    var dataManager: DataManagerProtocol!
    var interactor: MedicineInteractorProtocol!
    var medicine: Medicine = Medicine(name: "aaaa", unitsBox: 10, intervalSecs: 3600 * 8, unitsDose: 1)
    var timeManager: TimeManager = TimeManager()

     private var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        sut = MedicineCalendarVM(medicine: medicine, interactor: interactor, timeManager: timeManager)
    }

    func test_cycleDateRangesWhenTodayStartsCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 5 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020") //<- Today
//                      XCTAssertEqual(cycles[1], "02/03/2020")
//                      XCTAssertEqual(cycles[2], "03/03/2020")
//                      XCTAssertEqual(cycles[3], "04/03/2020")
//                      XCTAssertEqual(cycles[4], "05/03/2020")
                    
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .startPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .midFutureLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2), isCurrentMonth: true /*03/03/2020*/,
                                                                   timeManager: self.timeManager), .midFutureLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3), isCurrentMonth: true /*04/03/2020*/,
                                                                   timeManager: self.timeManager), .midFutureLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4), isCurrentMonth: true /*04/03/2020*/,
                                                                   timeManager: self.timeManager), .endFutureLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - (24 * 3600) * 5), isCurrentMonth: true /*06/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }
    
    func test_cycleDateRangesWhenTodayMiddleCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1)) //2-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2)) //3-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
//                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 5 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020")
//                      XCTAssertEqual(cycles[1], "02/03/2020")
//                      XCTAssertEqual(cycles[2], "03/03/2020") //<- Today
//                      XCTAssertEqual(cycles[3], "04/03/2020")
//                      XCTAssertEqual(cycles[4], "05/03/2020")
                    
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2), isCurrentMonth: true /*03/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3), isCurrentMonth: true /*04/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4), isCurrentMonth: true /*05/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - (24 * 3600) * 5), isCurrentMonth: true /*06/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }
    
    func test_cycleDateRangesWhenTodayEndCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1)) //2-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2)) //3-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3)) //4-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4)) //5-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 5 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020")
//                      XCTAssertEqual(cycles[1], "02/03/2020")
//                      XCTAssertEqual(cycles[2], "03/03/2020")
//                      XCTAssertEqual(cycles[3], "04/03/2020")
//                      XCTAssertEqual(cycles[4], "05/03/2020") //<- Today
                    
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .startPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2), isCurrentMonth: true /*03/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3), isCurrentMonth: true /*04/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4), isCurrentMonth: true /*05/03/2020*/,
                                                                   timeManager: self.timeManager), .endPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - (24 * 3600) * 5), isCurrentMonth: true /*06/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }
    
    func test_cycleDateRangesWhenTodayPastEndCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1)) //2-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2)) //3-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3)) //4-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4)) //5-March-2020
         interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 5)) //6-March-2020
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 5 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020")
//                      XCTAssertEqual(cycles[1], "02/03/2020")
//                      XCTAssertEqual(cycles[2], "03/03/2020")
//                      XCTAssertEqual(cycles[3], "04/03/2020")
//                      XCTAssertEqual(cycles[4], "05/03/2020")
                    //<- Today  "06/03/2020"
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .startPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 2), isCurrentMonth: true /*03/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 3), isCurrentMonth: true /*04/03/2020*/,
                                                                   timeManager: self.timeManager), .midPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 4), isCurrentMonth: true /*05/03/2020*/,
                                                                   timeManager: self.timeManager), .endPastLongCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 5), isCurrentMonth: true /*06/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }
    
    func test_cycleDateRangesWhenTodayIsShortCycle() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
      //   timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1)) //2-March-2020
        
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 1 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020") //<- Today
                    
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .dayCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }
    
    func test_cycleDateRangesWhenShortCycleIsPast() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        DataManager.shared.reset()
        dataManager = DataManager.shared
        interactor = MedicineInteractor(dataManager: dataManager)
        var testFinished = false

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }

        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
         timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1)) //2-March-2020
        
        let suscripiton = interactor.getMedicinesPublisher()
                  
                  suscripiton.sink(receiveCompletion: { completion in
                      XCTFail(".sink() received the completion:")
                  }, receiveValue: { someValue in
                    guard let medicine = someValue.first, !testFinished else { return }
                    self.sut = MedicineCalendarVM(medicine: medicine, interactor: self.interactor, timeManager: self.timeManager)
//                    let cycles = self.sut.doseIntervalsStr
//                      guard cycles.count == 1 else { XCTFail(); return }
//                      XCTAssertEqual(cycles[0], "01/03/2020") //<- Today
                    
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 - 24 * 3600), isCurrentMonth: true /*29/02/2020*/,
                                                                   timeManager: self.timeManager), .none)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800), isCurrentMonth: true /*01/03/2020*/,
                                                                   timeManager: self.timeManager), .dayCycle)
                    XCTAssertEqual(self.sut.getSelectionCicleType( date: Date(timeIntervalSince1970: 1583020800 + (24 * 3600) * 1), isCurrentMonth: true /*02/03/2020*/,
                                                                   timeManager: self.timeManager), .none)
                      testFinished = true
                    //  asyncExpectation.fulfill()
                  }).store(in: &cancellables)
              interactor.flushMedicines()
    }

}
