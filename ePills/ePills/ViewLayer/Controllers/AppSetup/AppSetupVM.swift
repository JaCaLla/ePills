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

    func tapped(menuOption: MenuOption) {
        if menuOption.title == R.string.localizable.setup_option_reset.key.localized {
            DataManager.shared.reset()
            StartUpAppSequencer().start()
        }
    }

    func menuSections() -> [MenuSection] {
        var sections: [MenuSection] = []

        var generalSection: MenuSection = MenuSection(name: R.string.localizable.setup_section_general.key.localized)
        generalSection.menuOptions.append(MenuOption(title:  R.string.localizable.setup_option_version.key.localized,
                                                     value: Bundle.main.releaseVersionNumber))
        sections.append(generalSection)

        var dataSection: MenuSection = MenuSection(name: R.string.localizable.setup_section_others.key.localized)
        dataSection.menuOptions.append(MenuOption(title:  R.string.localizable.setup_option_reset.key.localized,
                                                  value: nil))
        sections.append(dataSection)

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
