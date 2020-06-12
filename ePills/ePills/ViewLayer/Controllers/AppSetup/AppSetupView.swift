//
//  AppConfigurationView.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct AppSetupView: View {
    @ObservedObject var viewModel: AppSetupVM
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.menuSections()) { menuSection in
                    Section(header: Text(menuSection.name)) {
                        ForEach(menuSection.menuOptions) { menuOption in
                            HStack {
                                Text(menuOption.title)
                                Spacer()
                                Text(menuOption.getValue())
                            }
                            .foregroundColor(Color(R.color.colorBlack.name))
                            .onTapGesture {
                                self.viewModel.tapped(menuOption: menuOption)
                            }
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .foregroundColor(Color(R.color.colorBlack.name))
        .onAppear {
            AnalyticsManager.shared.logScreen(name: Screen.setup, flow: nil)
        }
    }
}

struct AppConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        AppSetupView(viewModel: AppSetupVM())
    }
}
