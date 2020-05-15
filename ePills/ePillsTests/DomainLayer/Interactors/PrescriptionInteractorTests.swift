//
//  cycleInteractorTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class cycleInteractorTests: XCTestCase {

    var sut: PrescriptionInteractor!
    var dataManagerMock: DataManagerMock = DataManagerMock()
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        DataManager.shared.reset()
        sut = PrescriptionInteractor(dataManager: self.dataManagerMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addcycleWhenDataManagerMock() throws {
        let medicine = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.add(medicine: medicine)
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }

    func test_addcycleWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)]]
        var expetedsIdx = 0

        let cycle = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.add(medicine: cycle)
        wait(for: [expectation], timeout: 0.1)
    }

    func test_removecycleWhenDataManagerMock() throws {
        let medicine = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.remove(medicine: medicine)
        XCTAssertEqual(dataManagerMock.removeCount, 1)
    }

    func test_removecycleWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)],
            [Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)],
            []]
        var expetedsIdx = 0

        let cycle = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        let cycle2 = Medicine(name: "b",
                                         unitsBox: 10,
                                         intervalSecs: 8,
                                         unitsDose: 1)
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.add(medicine: cycle)
        sut.remove(medicine: cycle2)
        sut.remove(medicine: cycle)
        wait(for: [expectation], timeout: 0.1)
    }

    func test_updatecycleWhenDataManagerMock() throws {
        let cycle = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.update(medicine: cycle)
        XCTAssertEqual(dataManagerMock.updateCount, 1)
    }

    func test_updatecycleWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Medicine]] = [
            [/*Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)],*/
            Medicine(name: "nameUpdated",
                          unitsBox: 20,
                          intervalSecs: 2,
                          unitsDose: 2)]
        ]
        var expetedsIdx = 0

        var cycle = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
          sut.add(medicine: cycle)
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
               // guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual([Medicine(name: "nameUpdated",
                unitsBox: 20,
                intervalSecs: 2,
                unitsDose: 2)], someValue)
                expectation.fulfill()

            }).store(in: &cancellables)
        // When
      
        cycle.name = "nameUpdated"
        cycle.unitsBox = 20
        cycle.intervalSecs = 2
        cycle.unitsDose = 2
        sut.update(medicine: cycle)
        wait(for: [expectation], timeout: 100.1)
    }
    
    func test_getIntervals_en() throws {
        // Update the language by swaping bundle
        Bundle.setLanguage(lang: "en")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 9 else {
            XCTFail()
            return
        }
        XCTAssertEqual(intervals[0].secs, 30)
        XCTAssertEqual(intervals[0].label, "_30 Secs")
        XCTAssertEqual(intervals[1].secs, 3600)
        XCTAssertEqual(intervals[1].label, "1 Hour")
        XCTAssertEqual(intervals[2].secs, 7200)
        XCTAssertEqual(intervals[2].label, "2 Hours")
        XCTAssertEqual(intervals[3].secs, 14400)
        XCTAssertEqual(intervals[3].label, "4 Hours")
        XCTAssertEqual(intervals[4].secs, 21600)
        XCTAssertEqual(intervals[4].label, "6 Hours")
        XCTAssertEqual(intervals[5].secs, 28800)
        XCTAssertEqual(intervals[5].label, "8 Hours")
        XCTAssertEqual(intervals[6].secs, 43200)
        XCTAssertEqual(intervals[6].label, "12 Hours")
        XCTAssertEqual(intervals[7].secs, 86400)
        XCTAssertEqual(intervals[7].label, "1 Day")
        XCTAssertEqual(intervals[8].secs, 172800)
        XCTAssertEqual(intervals[8].label, "2 Days")
    }
}
