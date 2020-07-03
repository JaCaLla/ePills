//
//  UTFileManager.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 18/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class UTLocalFileManager: XCTestCase {

    var sut: LocalFileManager = LocalFileManager.shared

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut.reset()
    }

    func test_saveOneImage() throws {
        let asyncExpectation = expectation(description: "\(#function)")

        LocalFileManager.shared.saveImage(imageName: "patata", image: R.image.testImage() ?? UIImage(), onComplete: { result in
            XCTAssertTrue(result)
            XCTAssertEqual(LocalFileManager.shared.count(), 1)
            asyncExpectation.fulfill()
        })

        self.waitForExpectations(timeout: 5, handler: nil)
    }

    func test_saveAndRetrieveImage() {
        let asyncExpectation = expectation(description: "\(#function)")

        LocalFileManager.shared.saveImage(imageName: "patata", image: R.image.testImage()!, onComplete: { result in
            XCTAssertTrue(result)
            LocalFileManager.shared.loadImage(fileName: "patata", onComplete: { image in
                XCTAssertNotNil(image)
                LocalFileManager.shared.reset()
                LocalFileManager.shared.loadImage(fileName: "patata", onComplete: { image in
                    XCTAssertNil(image)
                    asyncExpectation.fulfill()
                })
            })

        })

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func test_removeImage() {
        let asyncExpectation = expectation(description: "\(#function)")

        LocalFileManager.shared.saveImage(imageName: "patata", image: R.image.testImage()!, onComplete: { result in
            XCTAssertTrue(result)
            LocalFileManager.shared.loadImage(fileName: "patata", onComplete: { image in
                XCTAssertNotNil(image)
                LocalFileManager.shared.remove(filename: "patata")
                LocalFileManager.shared.loadImage(fileName: "patata", onComplete: { image in
                    XCTAssertNil(image)
                    asyncExpectation.fulfill()
                })
            })

        })
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
