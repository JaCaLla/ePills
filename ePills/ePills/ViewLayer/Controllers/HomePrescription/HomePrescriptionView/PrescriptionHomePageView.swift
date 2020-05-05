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

    // MARK: - Publishers
//    var onAddFirstPrescriptionPublisher: AnyPublisher<Prescription, Never> {
//        return onAddFirstPrescriptionSubject.eraseToAnyPublisher()
//    }
//    private var onAddFirstPrescriptionSubject = PassthroughSubject<Prescription, Never>()

    var prescription: Prescription
    @Binding var dosePrescription: Prescription?
    @Binding var onRemovingPrescription: Bool
    @Binding var currentPrescription: Prescription
     var viewModel: HomePrescriptionVM
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(viewModel.title())//prescription.title())
                    .font(.headline)
                    .foregroundColor(Color(R.color.colorWhite.name))
                    .padding(.leading)
                Spacer()
                Image(systemName: "minus.rectangle")
                    .font(Font.system(size: 20).bold())
                    .foregroundColor(Color.white)
                .padding()
                    .onTapGesture {
                        self.onRemovingPrescription = true
                        self.currentPrescription = self.prescription
                }
            }.frame(height: 50)
                .background(Color(R.color.colorGray50Semi.name))
           
            HStack {
                Spacer()
                Image(systemName: "plus.rectangle")
                    .font(Font.system(size: 20).bold())
                    .foregroundColor(Color.white)
                    .onTapGesture {
                        self.dosePrescription = self.prescription
                }
                Spacer()
            }.frame(height: 200)
                .background(Color.green)
            Spacer()
        }

    }

    init(prescription: Prescription,
         dosePrescription: Binding<Prescription?>,
         isRemovingPrescription: Binding<Bool>,
          curentPrescription: Binding<Prescription>,
          viewModel: HomePrescriptionVM) {
        self.prescription = prescription
        self._dosePrescription = dosePrescription
        self._onRemovingPrescription = isRemovingPrescription
        self._currentPrescription =  curentPrescription
        self.viewModel = viewModel
    }
}

//struct PrescriptionHomePageView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let prescription = Prescription(name: "Clamoxyl 200mg",
//                                        unitsBox: 20,
//                                        interval: Interval(secs: 8 * 3600, label: "Every 8 hours"),
//                                        unitsDose: 2)
//        return ZStack {
//            PrescriptionHomePageView(prescription: prescription,
//                                     dosePrescription: .constant(nil),
//                                     isRemovingPrescription: .constant(false),
//                                     curentPrescription: .constant(prescription))
//        }
//
//    }
//}
