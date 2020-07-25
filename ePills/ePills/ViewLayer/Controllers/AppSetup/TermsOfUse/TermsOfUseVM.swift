//
//  TermsOfUseVM.swift
//  ePills
//
//  Created by Javier Calatrava on 19/07/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit
//import Down

public final class TermsOfUseVM: ObservableObject {

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var atrTermsOfUse: NSAttributedString = NSAttributedString()

    func onPresented() {
        if let filepath = Bundle.main.path(forResource: "ToU", ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)

                let color = UIColor.darkGray
                let font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
                atrTermsOfUse = MarkDownParser.getAttributedStringFor(text: contents,
                                                                      bodyColor: color,
                                                                      bodyFont: font,
                                                                      boldColor: UIColor.black,
                                                                      linkColor: UIColor.blue,
                                                                      linkFont: font)
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }

    }
}
