//
//  DataManagerTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class DataManagerTests: XCTestCase {

    var sut: DataManager = DataManager()
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        sut.reset()
    }

    func test_reset() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)
// Given
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        sut.add(medicine: medicine)
        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                expectation.fulfill()
            }, receiveValue: { someValue in
                XCTAssertEqual(someValue, [])
                expectation.fulfill()
            }).store(in: &cancellables)


        // When
        sut.reset()

        wait(for: [expectation], timeout: 1.0)
    }
    
    func tests_isEmpty() {
        XCTAssertTrue(self.sut.isEmpty())
    }

    func test_StoreMedicinesAndGetMedicine() {

        let expectation = XCTestExpectation(description: self.debugDescription)

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                expectation.fulfill()
            }, receiveValue: { medicines in
                guard medicines.count == 1,
                    let medicine = medicines.first else { XCTFail(); return }
                XCTAssertEqual(medicine.name, "a")
                XCTAssertEqual(medicine.unitsBox, 10)
                XCTAssertEqual(medicine.intervalSecs, 8)
                XCTAssertEqual(medicine.unitsDose, 1)
                XCTAssertEqual(medicine.currentCycle.unitsConsumed, 0)
                XCTAssertNil(medicine.currentCycle.nextDose)
                XCTAssertEqual(medicine.pastCycles.count, 0)
                expectation.fulfill()
            }).store(in: &cancellables)


        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        switch DBManager.shared.create(medicine: medicine) {
        case .success(let medicineCreated):
            let cycle = Cycle(unitsConsumed: 0, nextDose: nil)
            switch DBManager.shared.create(cycle: cycle, medicineId: medicineCreated.id, timeManager: TimeManager()) {
            case .success:
                _ = sut.flushMedicines()
            default: XCTFail()
            }
        default:
            XCTFail()
        }


        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_addMedicineDose() {
              let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted2 = Medicine(name: "notStarted2",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted2.name = "aaa"
        notStarted2.unitsBox = 10
        notStarted2.intervalSecs = 11
        notStarted2.unitsDose = 2
        notStarted2.currentCycle.unitsConsumed = 1
        notStarted2.currentCycle.nextDose = nil
        notStarted2.currentCycle.creation = 2

        guard let newNotStarted2 = sut.add(medicine: notStarted2) else { XCTFail(); return }
        
        newNotStarted2.name = "bbb"
         newNotStarted2.unitsBox = 1
         newNotStarted2.intervalSecs = 12
         newNotStarted2.unitsDose = 1
         newNotStarted2.currentCycle.unitsConsumed = 1
         newNotStarted2.currentCycle.nextDose = 1
         newNotStarted2.currentCycle.creation = 2
         sut.update(medicine: newNotStarted2)
        
        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 1 else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(prescriptions[0].currentCycle.doses.count, 1)
                guard let firstDose = prescriptions[0].currentCycle.doses.first else {XCTFail(); expectation.fulfill(); return}
                XCTAssertEqual(firstDose.cycleId, prescriptions[0].currentCycle.id)
                XCTAssertEqual(firstDose.expected, 1)
                XCTAssertTrue(firstDose.id.contains("-"))
                XCTAssertEqual(firstDose.real, 5)
                
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        let timeManager = TimeManager()
                         timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 5))
        let dose = Dose(expected: newNotStarted2.currentCycle.nextDose ?? 1, timeManager: timeManager)
        sut.add(dose: dose, medicine: newNotStarted2)
        sut.flushMedicines()

        wait(for: [expectation], timeout: 2)
    }

    func test_getPrescriptions() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        // Given
        let prescription = Medicine(name: "a",
                                    unitsBox: 10,
                                    intervalSecs: 8,
                                    unitsDose: 1)

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                expectation.fulfill()
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Medicine(name: "a",
                                                    unitsBox: 10,
                                                    intervalSecs: 8,
                                                    unitsDose: 1)])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(medicine: prescription)
        wait(for: [expectation], timeout: 0.1)

    }

    func test_addPrescriptions() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let prescription1 = Medicine(name: "a",
                                     unitsBox: 10,
                                     intervalSecs: 8,
                                     unitsDose: 1)

        sut.add(medicine: prescription1)

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                expectation.fulfill()
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Medicine(name: "a",
                                                    unitsBox: 10,
                                                    intervalSecs: 8,
                                                    unitsDose: 1),
                                           Medicine(name: "b",
                                                    unitsBox: 5,
                                                    intervalSecs: 4,
                                                    unitsDose: 2)
                ])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        let prescription2 = Medicine(name: "b",
                                     unitsBox: 5,
                                     intervalSecs: 4,
                                     unitsDose: 2)
        sut.add(medicine: prescription2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_getPresciptionsWhenManyNotStarted() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted1 = Medicine(name: "notStarted3",
                                   unitsBox: 10,
                                   intervalSecs: 4,
                                   unitsDose: 1)
        notStarted1.currentCycle.creation = 3
        let notStarted2 = Medicine(name: "notStarted1",
                                   unitsBox: 10,
                                   intervalSecs: 4,
                                   unitsDose: 1)
        notStarted2.currentCycle.creation = 1
        let notStarted3 = Medicine(name: "notStarted2",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted3.currentCycle.creation = 2
        sut.add(medicine: notStarted3)
        sut.add(medicine: notStarted1)

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { medicines in
                // Then
                guard medicines.count == 3 else {
                    XCTFail()
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(medicines[0].name, "notStarted2")
                XCTAssertEqual(medicines[0].getState(), .notStarted)
                XCTAssertEqual(medicines[1].name, "notStarted3")
                XCTAssertEqual(medicines[1].getState(), .notStarted)
                XCTAssertEqual(medicines[2].name, "notStarted1")
                XCTAssertEqual(medicines[2].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(medicine: notStarted2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_removePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted1 = Medicine(name: "notStarted1",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted1.currentCycle.creation = 1
        let notStarted2 = Medicine(name: "notStarted2",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted2.currentCycle.creation = 2
        let notStarted3 = Medicine(name: "notStarted3",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted3.currentCycle.creation = 3
        sut.add(medicine: notStarted3)
        sut.add(medicine: notStarted1)
        guard let newNotStarted2 = sut.add(medicine: notStarted2) else { XCTFail(); return }

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 2 else {
                    XCTFail()
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(prescriptions[0].name, "notStarted3")
                XCTAssertEqual(prescriptions[0].getState(), .notStarted)
                XCTAssertEqual(prescriptions[1].name, "notStarted1")
                XCTAssertEqual(prescriptions[1].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.remove(medicine: newNotStarted2)

        wait(for: [expectation], timeout: 1.1)
    }

    func test_updatePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted2 = Medicine(name: "notStarted2",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted2.name = "aaa"
        notStarted2.unitsBox = 10
        notStarted2.intervalSecs = 11
        notStarted2.unitsDose = 2
        notStarted2.currentCycle.unitsConsumed = 1
        notStarted2.currentCycle.nextDose = nil
        notStarted2.currentCycle.creation = 2

        guard let newNotStarted2 = sut.add(medicine: notStarted2) else { XCTFail(); return }

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 1 else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(prescriptions[0].name, "bbb")
                XCTAssertEqual(prescriptions[0].unitsBox, 1)
                XCTAssertEqual(prescriptions[0].intervalSecs, 12)
                XCTAssertEqual(prescriptions[0].unitsDose, 1)
                XCTAssertEqual(prescriptions[0].pastCycles.count, 0)
                XCTAssertEqual(prescriptions[0].currentCycle.unitsConsumed, 1)
                XCTAssertEqual(prescriptions[0].currentCycle.nextDose, 1)
                XCTAssertEqual(prescriptions[0].getState(), .finished)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        newNotStarted2.name = "bbb"
        newNotStarted2.unitsBox = 1
        newNotStarted2.intervalSecs = 12
        newNotStarted2.unitsDose = 1
        newNotStarted2.currentCycle.unitsConsumed = 1
        newNotStarted2.currentCycle.nextDose = 1
        newNotStarted2.currentCycle.creation = 2
        sut.update(medicine: newNotStarted2)

        wait(for: [expectation], timeout: 2)
    }

    func test_updatePrescriptionWhenCycleIsPast() {
      //  un ciclo se tiene que marcar como current para poderlo recuperar
       let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted2 = Medicine(name: "notStarted2",
                                   unitsBox: 10,
                                   intervalSecs: 8,
                                   unitsDose: 1)
        notStarted2.name = "aaa"
        notStarted2.unitsBox = 10
        notStarted2.intervalSecs = 11
        notStarted2.unitsDose = 2
        notStarted2.currentCycle.unitsConsumed = 1
        notStarted2.currentCycle.nextDose = nil
        notStarted2.currentCycle.creation = 2

        guard let newNotStarted2 = sut.add(medicine: notStarted2) else { XCTFail(); return }

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 1 else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(prescriptions[0].name, "bbb")
                XCTAssertEqual(prescriptions[0].unitsBox, 10)
                XCTAssertEqual(prescriptions[0].intervalSecs, 12)
                XCTAssertEqual(prescriptions[0].unitsDose, 10)
                XCTAssertEqual(prescriptions[0].pastCycles.count, 0)
                XCTAssertEqual(prescriptions[0].currentCycle.unitsConsumed, 10)
                XCTAssertEqual(prescriptions[0].currentCycle.nextDose, 1)
                XCTAssertEqual(prescriptions[0].getState(), .finished)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        newNotStarted2.name = "bbb"
        newNotStarted2.unitsBox = 10
        newNotStarted2.intervalSecs = 12
        newNotStarted2.unitsDose = 10
        newNotStarted2.currentCycle.unitsConsumed = 10
        newNotStarted2.currentCycle.nextDose = 1
        newNotStarted2.currentCycle.creation = 2
        sut.update(medicine: newNotStarted2)

        wait(for: [expectation], timeout: 2)
    }

    
    func test_updatePrescriptionWhenCycleIsNotPast() {
        let expectation = XCTestExpectation(description: self.debugDescription)
               // Given
               let notStarted2 = Medicine(name: "notStarted2",
                                          unitsBox: 10,
                                          intervalSecs: 8,
                                          unitsDose: 1)
               notStarted2.name = "aaa"
               notStarted2.unitsBox = 10
               notStarted2.intervalSecs = 11
               notStarted2.unitsDose = 2
               notStarted2.currentCycle.unitsConsumed = 1
               notStarted2.currentCycle.nextDose = nil
               notStarted2.currentCycle.creation = 2

               guard let newNotStarted2 = sut.add(medicine: notStarted2) else { XCTFail(); return }

               sut.getMedicinesPublisher()
                   .sink(receiveCompletion: { completion in
                       XCTFail(".sink() received the completion:")
                   }, receiveValue: { prescriptions in
                       // Then
                       guard prescriptions.count == 1 else {
                           XCTFail()
                           return
                       }

                       XCTAssertEqual(prescriptions[0].name, "bbb")
                       XCTAssertEqual(prescriptions[0].unitsBox, 10)
                       XCTAssertEqual(prescriptions[0].intervalSecs, 12)
                       XCTAssertEqual(prescriptions[0].unitsDose, 5)
                       XCTAssertEqual(prescriptions[0].pastCycles.count, 0)
                       XCTAssertEqual(prescriptions[0].currentCycle.unitsConsumed, 5)
                       XCTAssertEqual(prescriptions[0].currentCycle.nextDose, 1)
                       XCTAssertEqual(prescriptions[0].getState(), .ongoingEllapsed)
                       expectation.fulfill()
                   }).store(in: &cancellables)
               // When
               newNotStarted2.name = "bbb"
               newNotStarted2.unitsBox = 10
               newNotStarted2.intervalSecs = 12
               newNotStarted2.unitsDose = 5
               newNotStarted2.currentCycle.unitsConsumed = 5
               newNotStarted2.currentCycle.nextDose = 1
               newNotStarted2.currentCycle.creation = 2
               sut.update(medicine: newNotStarted2)

               wait(for: [expectation], timeout: 2)
    }

    
    func test_fetchDoses() {
        let cycleId = givenCycleWithDoses(medicineId: UUID().uuidString, real: [3, 1, 2])
        let doses: [Dose] = sut.fetchDoses(cycleId: cycleId)
        guard doses.count == 3 else { XCTFail(); return }
        XCTAssertEqual(doses[0].real, 1)
        XCTAssertEqual(doses[1].real, 2)
        XCTAssertEqual(doses[2].real, 3)

    }

    func test_fetchCycles() {
        let medicineId = givenMedicineWithCyclesAndoDoses(real: [[3, 1, 2], [30, 10], [300, 100, 200]])
        let cycles: [Cycle] = sut.fetchCycles(medicineId: medicineId)
        guard cycles.count == 3 else { XCTFail(); return }

        var doses = cycles[0].doses
        guard doses.count == 3 else { XCTFail(); return }
        XCTAssertEqual(doses[0].real, 1)
        XCTAssertEqual(doses[1].real, 2)
        XCTAssertEqual(doses[2].real, 3)

        doses = cycles[1].doses
        guard doses.count == 2 else { XCTFail(); return }
        XCTAssertEqual(doses[0].real, 10)
        XCTAssertEqual(doses[1].real, 30)

        doses = cycles[2].doses
        guard doses.count == 3 else { XCTFail(); return }
        XCTAssertEqual(doses[0].real, 100)
        XCTAssertEqual(doses[1].real, 200)
        XCTAssertEqual(doses[2].real, 300)
    }

    func test_fetchOneMedicine2CyclesOneOngoingOneGone() {
        let medicine = Medicine(name: "aaaaa", unitsBox: 2, intervalSecs: 20, unitsDose: 1)
        switch DBManager.shared.create(medicine: medicine) {
        case .success(let createdMedicine):
            let timeManager = TimeManager()
                   timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
            let cycleGone = Cycle(unitsConsumed: 2, nextDose: nil, timeManager: timeManager)
            cycleGone.id = UUID().uuidString
            cycleGone.medicineId = createdMedicine.id
            switch DBManager.shared.create(cycle: cycleGone, medicineId: cycleGone.medicineId, timeManager: timeManager) {
            case .success:
                 timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 10))
                let cycleOngoing = Cycle(unitsConsumed: 1, nextDose: 1, timeManager:timeManager)
                cycleOngoing.id = UUID().uuidString
                cycleOngoing.medicineId = createdMedicine.id
                 switch DBManager.shared.create(cycle: cycleOngoing, medicineId: cycleOngoing.medicineId, timeManager: timeManager) {
                case .success:
                    // When
                    guard let medicine = sut.fetchStoredMedicines().first else { XCTFail(); return }
                    XCTAssertEqual(medicine.currentCycle.unitsConsumed, 1)
                    XCTAssertEqual(medicine.currentCycle.nextDose!, 1)
                    XCTAssertEqual(medicine.currentCycle.update, 10)
                    XCTAssertEqual(medicine.currentCycle.creation, 10)
                    guard let goneCycle = medicine.pastCycles.first else { XCTFail(); return }
                    XCTAssertEqual(goneCycle.unitsConsumed, 2)
                    XCTAssertEqual(goneCycle.update, 0)
                    XCTAssertEqual(goneCycle.creation, 0)
                    XCTAssertNil(goneCycle.nextDose)
                default: break
                }
            default: break
            }
        default: break
        }
    }

    func test_updateMedicine() {
        let medicine = Medicine(name: "aaaaa", unitsBox: 2, intervalSecs: 20, unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine) else { XCTFail(); return }
        var medicines = sut.fetchStoredMedicines()
        // When
        createdMedicine.name = "bbbbb"
        createdMedicine.unitsBox = 20
        createdMedicine.intervalSecs = 200
        createdMedicine.unitsDose = 10
        createdMedicine.currentCycle.unitsConsumed = 1
        createdMedicine.currentCycle.nextDose = 2
        createdMedicine.currentCycle.creation = 1
        sut.update(medicine: createdMedicine)
        medicines = sut.fetchStoredMedicines()
        guard let updatedMedicine = sut.fetchStoredMedicines().first(where: { $0.id == createdMedicine.id }) else { XCTFail(); return }
        // let updatedMedicine = sut.fetchStoredMedicines()[index]
        XCTAssertEqual(updatedMedicine.name, "bbbbb")
        XCTAssertEqual(updatedMedicine.unitsBox, 20)
        XCTAssertEqual(updatedMedicine.intervalSecs, 200)
        XCTAssertEqual(updatedMedicine.unitsDose, 10)
        XCTAssertEqual(updatedMedicine.currentCycle.unitsConsumed, 1)
        XCTAssertEqual(updatedMedicine.currentCycle.nextDose, 2)
        XCTAssertEqual(updatedMedicine.getState(), .ongoingEllapsed)
    }

    func test_updateCurrentCycle() {
        let medicine = Medicine(name: "aaaaa", unitsBox: 2, intervalSecs: 20, unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine) else { XCTFail(); return }

        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        createdMedicine.takeDose(timeManager: timeManager)

        sut.update(medicine: createdMedicine)
        guard let updatedMedicine = sut.fetchStoredMedicines().first(where: { $0.id == createdMedicine.id }) else { XCTFail(); return }
        XCTAssertEqual(updatedMedicine.name, "aaaaa")
        XCTAssertEqual(updatedMedicine.unitsBox, 2)
        XCTAssertEqual(updatedMedicine.intervalSecs, 20)
        XCTAssertEqual(updatedMedicine.unitsDose, 1)
        XCTAssertEqual(updatedMedicine.currentCycle.unitsConsumed, 1)
        XCTAssertEqual(updatedMedicine.currentCycle.nextDose, 20)
        XCTAssertEqual(updatedMedicine.getState(), .ongoingEllapsed)
    }

}



func givenMedicineWithCyclesAndoDoses(real: [[Double]]) -> String {
    let medicine = Medicine(name: "aaaaa", unitsBox: 20, intervalSecs: 20, unitsDose: 1)
    switch DBManager.shared.create(medicine: medicine) {
    case .success(let createdMedicine):
        real.forEach({
            givenCycleWithDoses(medicineId: createdMedicine.id, real: $0)
        })
        return createdMedicine.id
    default: break
    }
    return ""
}

func givenCycleWithDoses(medicineId: String, real: [Double]) -> String {
    let cycle = Cycle(unitsConsumed: 0, nextDose: nil)
    cycle.id = UUID().uuidString
    cycle.medicineId = medicineId
    switch DBManager.shared.create(cycle: cycle, medicineId: medicineId, timeManager: TimeManager()) {
    case .success(let createdCycle):
        let timeManager = TimeManager()
        real.forEach({
            timeManager.setInjectedDate(date: Date(timeIntervalSince1970: $0))
            let dose = Dose(expected: 22, timeManager: timeManager)
            DBManager.shared.create(dose: dose, cycleId: createdCycle.id)
        })
        return createdCycle.id
    default: break
    }

    return ""
}
