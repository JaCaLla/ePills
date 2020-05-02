//
//  PrescriptionHomePageView.swift
//  ePills
//
//  Created by Javier Calatrava on 28/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct PrescriptionHomePageView: View {

    var prescription: Prescription
    @Binding var dosePrescription: Prescription?
    @Binding var isRemovingPrescription: Bool
    @Binding var onEditing: Prescription?
    @Binding var currentPrescription: Prescription
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text(self.prescription.title())
                        .font(.headline)
                        .foregroundColor(Color(R.color.colorWhite.name))
                        .padding(.leading)
                    Spacer()
                    Image(systemName: "minus.rectangle")
                        .font(Font.system(size: 20).bold())
                        .foregroundColor(Color.white)
                        .padding()
                        .onTapGesture {
                            self.isRemovingPrescription = true
                            self.currentPrescription = self.prescription
                    }
                }.frame(height: geometry.size.height * 0.125)
                    .background(Color(R.color.colorGray50Semi.name))

                HStack {
                    Spacer()
                    Image(systemName: "plus.rectangle")
                        .font(Font.system(size: 20).bold())
                        .foregroundColor(Color.white)
                    Spacer()
                }.frame(height: geometry.size.height / 4)
                    .background(Color.blue)
                HStack {
                    Spacer()
                    Image(systemName: "plus.rectangle")
                        .font(Font.system(size: 20).bold())
                        .foregroundColor(Color.white)
                        .onTapGesture {
                            self.dosePrescription = self.prescription
                    }
                    Spacer()
                }.frame(height: geometry.size.height * 0.375)
                    .background(Color.green)
                HStack {
                    Spacer()
//                    Image(systemName: "square.and.pencil")
//                        .font(Font.system(size: 20).bold())
//                        .foregroundColor(Color.white)
//                        .onTapGesture {
//                            self.onEditing = self.prescription
//                    }
                    PrescriptionButtonView(iconName: "square.and.pencil", action: {
                        self.onEditing = self.prescription
                    })
                    Spacer()
                }.frame(height: geometry.size.height / 4)
                //.background(Color.yellow)
                Spacer()
            }
        }
    }

    init(prescription: Prescription,
         dosePrescription: Binding<Prescription?>,
         isRemovingPrescription: Binding<Bool>,
         onEditing: Binding<Prescription?>,
         curentPrescription: Binding<Prescription>) {
        self.prescription = prescription
        self._dosePrescription = dosePrescription
        self._isRemovingPrescription = isRemovingPrescription
        self._onEditing = onEditing
        self._currentPrescription = curentPrescription
    }
}

struct PrescriptionHomePageView_Previews: PreviewProvider {

    static var previews: some View {
        let prescription = Prescription(name: "Clamoxyl 200mg",
                                        unitsBox: 20,
                                        interval: Interval(hours: 8, label: "Every 8 hours"),
                                        unitsDose: 2)
        return ZStack {
            PrescriptionHomePageView(prescription: prescription,
                                     dosePrescription: .constant(nil),
                                     isRemovingPrescription: .constant(false),
                                     onEditing: .constant(nil),
                                     curentPrescription: .constant(prescription))
        }

    }
}
