//
//  DoseListCellView.swift
//  ePills
//
//  Created by Javier Calatrava on 07/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct DoseListCellView: View {
    var doseCellViewModel: DoseCellViewModel
    var body: some View {
        HStack {
             DoseCellTypeView(doseCellViewModel: doseCellViewModel)
            Text(doseCellViewModel.day)
                .fontWeight(.light)
                .frame(alignment: .leading)
                .font(Font.system(size: 45, design: .default))
                .padding()
            VStack {
                Text(doseCellViewModel.monthYear).fontWeight(.light)
                Text(doseCellViewModel.weekdayHHMM).fontWeight(.light)
            }.frame(alignment: .leading)
                .font(Font.system(size: 15, design: .default))
            Spacer()
            Text(doseCellViewModel.realOffset)
                .foregroundColor(Color(doseCellViewModel.realOffsetColorStr))
        }.padding(.vertical, -20)
    }
}

struct DoseListCellView_Previews: PreviewProvider {
    static var doseCellViewModel: DoseCellViewModel {
        DoseCellViewModel(doseOrder: "",
                          day: "",
                          monthYear: "",
                          weekdayHHMM: "",
                          realOffset: "",
                          realOffsetColorStr: "",
                          doseCellType: .middle)
    }
    static var previews: some View {
        DoseListCellView(doseCellViewModel: DoseListCellView_Previews.doseCellViewModel)
    }
}
/*
 
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
 
 */
