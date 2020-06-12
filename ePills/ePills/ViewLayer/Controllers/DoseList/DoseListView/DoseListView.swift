//
//  DoseListView.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct DoseListView: View {
    @ObservedObject var viewModel: DoseListVM

    init(viewModel: DoseListVM) {
        self.viewModel = viewModel
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().tableFooterView = UIView()
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack {
            BackgroundView()
            List {
                ForEach(viewModel.getDoses()) { doseCellViewModel in
                    DoseListCellView(doseCellViewModel: doseCellViewModel)
                }
            }
        }.navigationBarTitle(R.string.localizable.dose_list_title.key.localized)
        .onAppear {
            AnalyticsManager.shared.logScreen(name: Screen.doseList, flow: nil)
        }
    }
}

struct DoseListView_Previews: PreviewProvider {
    static var viewModel: DoseListVM {
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800))
        medicine.currentCycle.doses.append(Dose(expected: 1583020800, timeManager: timeManager))
        return DoseListVM(medicine: medicine)
    }

    static var previews: some View {
        DoseListView(viewModel: DoseListView_Previews.viewModel)
    }
}
