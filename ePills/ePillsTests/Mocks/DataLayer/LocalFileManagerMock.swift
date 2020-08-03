//
//  LocalFileManagerMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 20/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation
import UIKit

class LocalFileManagerMock: LocalFileManagerProtocol {

    var saveImageCount: Int = 0
    var loadImageCount: Int = 0
    var removeAllImagesCount: Int = 0
    var removeCount: Int = 0
    var countCount: Int = 0

    var image: UIImage?

    func saveImage(imageName: String, image: UIImage, onComplete: (Bool) -> ()) {
        saveImageCount += 1
    }

    func loadImage(fileName: String, onComplete: (UIImage?) -> ()) {
        loadImageCount += 1
        onComplete(image)
    }

    func removeAllImages() {
        removeAllImagesCount += 1
    }

    func remove(filename: String) {
        removeCount += 1
    }

    func count() -> Int {
        countCount += 1
        return self.image != nil ? 1 : 0
    }
}
