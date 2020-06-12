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
                .foregroundColor(Color(R.color.colorWhite.name))
                .fontWeight(.light)
                .frame(alignment: .leading)
                .font(Font.system(size: 45, design: .default))
                .padding()
            VStack {
                Text(doseCellViewModel.monthYear).fontWeight(.light)
                Text(doseCellViewModel.weekdayHHMM).fontWeight(.light)
            }.frame(alignment: .leading)
                .foregroundColor(Color(R.color.colorWhite.name))
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
