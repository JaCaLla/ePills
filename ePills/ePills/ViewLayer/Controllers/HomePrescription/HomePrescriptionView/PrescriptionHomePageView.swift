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

    var medicine: Medicine
    @Binding var isRemovingPrescription: Bool
    @Binding var currentMedicine: Medicine
     var viewModel: HomePrescriptionVM
    
    // MARK: - Private attributes
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @State var now = Date()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text(self.viewModel.title())
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
                            self.currentMedicine = self.medicine
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
                  //  .background(Color.blue)
                HStack {
                   // Spacer()
                    VStack {
                        Image(systemName: self.viewModel.prescriptionIcon)
                            .font(Font.system(size: 60).bold())
                            .foregroundColor(Color(self.viewModel.prescriptionColor))
                            .onTapGesture {
                               // self.dosePrescription = self.prescription
                                self.viewModel.takeDose()
                        }
                        Text(self.viewModel.prescriptionMessage)
                            .font(.body).padding(.vertical)
                            .foregroundColor(Color(self.viewModel.prescriptionColor))
                        HStack(alignment: .firstTextBaseline) {
                            Spacer()
                            Text(self.viewModel.remainingMessageMajor)
                                .font(.largeTitle)//.padding()
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                             Text(self.viewModel.remainingMessageMinor)
                                .font(.headline)
                                .foregroundColor(Color(self.viewModel.prescriptionColor)).padding(.leading, 5)
                            Spacer()
                        }//.background(Color.blue)
                    }//.background(Color.gray)
                    
                   // Spacer()
                }.frame(height: geometry.size.height * 0.375)
                //.background(Color.green)
                HStack {
                    Spacer()
                    if (self.viewModel.isUpdatable) {
                    PrescriptionButtonView(iconName: "square.and.pencil", action: {
                        self.viewModel.update()
                        })
                    }
                    Spacer()
                }.frame(height: geometry.size.height / 4)
                Spacer()
            }
        }
    }

    init(medicine: Medicine,
         isRemovingPrescription: Binding<Bool>,
         curentPrescription: Binding<Medicine>,
         viewModel: HomePrescriptionVM) {
        self.medicine = medicine
        self._isRemovingPrescription = isRemovingPrescription
        self._currentMedicine = curentPrescription
        self.viewModel = viewModel
    }
}

struct PrescriptionHomePageView_Previews: PreviewProvider {

    static var previews: some View {
        let prescription = Medicine(name: "Clamoxyl 200mg",
                                        unitsBox: 20,
                                        intervalSecs: 8,
                                        unitsDose: 2)
        let viewModel = HomePrescriptionVM(homeCoordinator: HomeCoordinator())
        return ZStack {
            PrescriptionHomePageView(medicine: prescription,
                                     isRemovingPrescription: .constant(false),
                                     curentPrescription: .constant(prescription), viewModel: viewModel)
        }

    }
}
