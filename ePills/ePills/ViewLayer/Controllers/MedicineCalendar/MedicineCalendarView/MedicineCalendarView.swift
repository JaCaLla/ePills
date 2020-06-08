//
//  MedicineCalendarView.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct MedicineCalendarView: View {
    @ObservedObject var viewModel: MedicineCalendarVM
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                CalendarHeaderView(viewModel: viewModel).onTapGesture {
                    self.viewModel.onScrollToExpirationDateSubject.send()
                }
                CalendarView(viewModel: viewModel)
                    .padding(.top, -60)
            }
        }.navigationBarTitle(R.string.localizable.calendar_title.key.localized)
    }
}

struct MedicineCalendarView_Previews: PreviewProvider {

    static var viewModel: MedicineCalendarVM {
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        return MedicineCalendarVM(medicine: medicine)
    }

    static var previews: some View {
        ZStack {
            BackgroundView()
            MedicineCalendarView(viewModel: MedicineCalendarView_Previews.viewModel)
        }
    }
}
