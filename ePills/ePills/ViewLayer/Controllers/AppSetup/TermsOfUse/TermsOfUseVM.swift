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
import Down

public final class TermsOfUseVM: ObservableObject {
    
    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var strTemsOfUSe: String = ""
    
    func onPresented() {
        
        self.strTemsOfUSe = "asdfasdfafsd"
        
    }
}
