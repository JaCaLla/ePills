//
//  AppSetupVM.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public final class AppSetupVM: ObservableObject {
    
    // MARK: - Publishers
    var onToSSelectedPublisher: AnyPublisher<Void, Never> {
        return onToSSelectedSubject.eraseToAnyPublisher()
    }
    private var onToSSelectedSubject = PassthroughSubject<Void, Never>()

    func tapped(menuOption: MenuOption) {
        if menuOption.title == R.string.localizable.setup_option_reset.key.localized {
            DataManager.shared.reset()
            StartUpAppSequencer().start()
        } else if menuOption.title == R.string.localizable.setup_option_terms_of_use.key.localized {
            onToSSelectedSubject.send()
        }
    }

    func menuSections() -> [MenuSection] {
        var sections: [MenuSection] = []

        var generalSection: MenuSection = MenuSection(name: R.string.localizable.setup_section_general.key.localized)
        let titleVersion = R.string.localizable.setup_option_version.key.localized
        generalSection.menuOptions.append(MenuOption(title: titleVersion, value: Bundle.main.releaseVersionNumber))
        let termsOfUse = R.string.localizable.setup_option_terms_of_use.key.localized
        generalSection.menuOptions.append(MenuOption(title: termsOfUse, value: nil))
        sections.append(generalSection)
        
        #if DEBUG
            var dataSection: MenuSection = MenuSection(name: R.string.localizable.setup_section_others.key.localized)
            let titleReset = R.string.localizable.setup_option_reset.key.localized
            dataSection.menuOptions.append(MenuOption(title: titleReset, value: nil))
            sections.append(dataSection)
        #endif
        return sections
    }
}

struct MenuSection: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var menuOptions: [MenuOption] = []
}

struct MenuOption: Codable, Equatable, Identifiable {
    let id: UUID = UUID()
    var title: String
    var value: String?

    func getValue() -> String {
        guard let uwpValue = self.value else { return "" }
        return uwpValue
    }
}
