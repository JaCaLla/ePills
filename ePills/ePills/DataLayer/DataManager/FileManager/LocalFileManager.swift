//
//  FileManager.swift
//  wgs
//
//  Created by 08APO0516 on 08/03/2019.
//  Copyright © 2019 jca. All rights reserved.
//

import Foundation
import CocoaLumberjack
import UIKit

protocol LocalFileManagerProtocol {
    func saveImage(imageName: String, image: UIImage, onComplete: (Bool) -> Void)
    func loadImage(fileName: String, onComplete: (UIImage?) -> Void)
    func removeAllImages()
    func remove(filename: String)
    func count() -> Int
}

final class LocalFileManager {

    static let shared: LocalFileManager = LocalFileManager()

    private init() { /* For not overwriting singleton*/ }
}

extension LocalFileManager: LocalFileManagerProtocol {

    func saveImage(imageName: String, image: UIImage, onComplete: (Bool) -> Void) {

        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        if !fileManager.fileExists(atPath: path as String) {
            do {
                try fileManager.createDirectory(atPath: path as String,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                DDLogError("\(error)")
                onComplete(false)
            }
        }
        guard let url = NSURL(string: path as String),
            let imagePath = url.appendingPathComponent(imageName),
            let rotatedImage = self.rotateImage(image: image) else {
                onComplete(false)
                return
        }
        let urlString: String = imagePath.absoluteString
        fileManager.createFile(atPath: urlString as String, contents: rotatedImage.pngData() ?? Data(), attributes: nil)
        onComplete(true)
    }

    func loadImage(fileName: String, onComplete: (UIImage?) -> Void = { _ in /* Default empty block */ }) {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            do {
                let data = try Data(contentsOf: imageUrl)
                onComplete(UIImage(data: data))
            } catch {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }

    func removeAllImages() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            DDLogError("\("error")")
        }
    }

    func remove(filename: String) {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first else {
            return
        }

        let fileURL = documentsDirectory.appendingPathComponent(filename)
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch let error {
                DDLogError("couldn't remove file at path \(error)")
            }
        }
    }

    func count() -> Int {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return 0
        }
        do {
            let fileURLs =
                try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                            includingPropertiesForKeys: nil,
                                                            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            return fileURLs.count
        } catch {
            DDLogError("ERROR: Failed image count")
            return 0
        }
    }

    // MARK: - Private/Internal
    private func rotateImage(image: UIImage) -> UIImage? {
        guard (image.imageOrientation != UIImage.Orientation.up) else { return image }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}

extension LocalFileManager: Resetable {
    func reset() {
        self.removeAllImages()
    }
}
