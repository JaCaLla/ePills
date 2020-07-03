//
//  CalendarHeaderView.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct CalendarHeaderView: View {
    @ObservedObject var viewModel: MedicineCalendarVM
    var body: some View {
        VStack {
            Text(R.string.localizable.calendar_last_dose.key.localized)
                .fontWeight(.light)
                .frame(alignment: .leading)
                .padding(.vertical, 10)
            HStack {
                Spacer()
                Text(viewModel.expirationDayNumber)
                    .fontWeight(.light)
                    .frame(alignment: .leading)
                    .font(Font.system(size: 90, design: .default))
                    .padding()
                VStack {
                    Text(viewModel.expirationMonthYear).fontWeight(.light)
                    Text(viewModel.expirationWeekdayHourMinute).fontWeight(.light)
                }.frame(alignment: .leading)
                    .font(Font.system(size: 30, design: .default))
                    .padding(.trailing, 10)
                Spacer()
            } .padding(.top, -40)
        }.frame(height: 130)
            .foregroundColor(Color(R.color.colorWhite.name))
            .background(Color(R.color.colorGray50Semi.name))
    }
}

struct CalendarHeaderView_Previews: PreviewProvider {
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
            CalendarHeaderView(viewModel: MedicineCalendarView_Previews.viewModel)
        }
    }
}
