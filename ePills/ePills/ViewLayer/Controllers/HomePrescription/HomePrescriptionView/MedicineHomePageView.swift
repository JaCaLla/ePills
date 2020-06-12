//
//  PrescriptionHomePageView.swift
//  ePills
//
//  Created by Javier Calatrava on 28/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct MedicineHomePageView: View {

    var medicine: Medicine
    @Binding var isRemovingPrescription: Bool
    @Binding var currentMedicine: Medicine
    var viewModel: HomePrescriptionVM

    // MARK: - Private attributes
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @State var now = Date()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArcShape(width: geometry.size.width, height: geometry.size.height, progress: 1)
                    .stroke(lineWidth: 10)
                    .fill(Color(R.color.colorGray50Semi.name))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                ArcShape(width: geometry.size.width, height: geometry.size.height,
                         progress: self.viewModel.progressPercentage)
                    .stroke(lineWidth: 10)
                    .fill(Color(R.color.colorWhite.name))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Text(self.viewModel.title())
                            .font(.headline)
                            .foregroundColor(Color(R.color.colorWhite.name))
                            .padding(.leading)
                        Spacer()
                        Image(systemName: "minus.rectangle")
                            .font(Font.system(size: 20).bold())
                            .foregroundColor(Color(R.color.colorWhite.name))
                            .padding()
                            .onTapGesture {
                                self.isRemovingPrescription = true
                                self.currentMedicine = self.medicine
                        }
                    }.frame(height: geometry.size.height * 0.125)
                        .background(Color(R.color.colorGray50Semi.name))
                    VStack {
                        HStack {
                            Spacer()
                            if !self.viewModel.prescriptionTime.isEmpty {
                                Image(systemName: "alarm")
                                    .foregroundColor(Color(R.color.colorWhite.name))
                                    .font(Font.system(size: 30)
                                        .bold())
                                Text(self.viewModel.prescriptionTime)
                                    .font(Font.system(size: 30).bold())
                                    .foregroundColor(Color(R.color.colorWhite.name))
                            }
                            Spacer()
                        }
                        Spacer()
                    }.padding().frame(height: geometry.size.height * 0.2)
                    HStack {
                        VStack {
                            Image(systemName: self.viewModel.prescriptionIcon)
                                .font(Font.system(size: 60).bold())
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                                .onTapGesture {
                                    self.viewModel.takeDose()
                            }
                            Text(self.viewModel.prescriptionMessage)
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .padding(.vertical)
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                            HStack(alignment: .firstTextBaseline) {
                                Spacer()
                                Text(self.viewModel.remainingMessageMajor)
                                    .font(Font.system(size: 48).bold())//.font(.largeTitle)//.padding()
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                                Text(self.viewModel.remainingMessageMinor)
                                    .font(Font.system(size: 15).bold())// .font(.headline)
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                                    .padding(.leading, -5)
                                Spacer()
                            }
                            Spacer()
                        }
                    }.frame(height: geometry.size.height * 0.475)
                    HStack {
                        VStack {
                            PrescriptionButtonView(iconName: "calendar", action: {
                                AnalyticsManager.shared.logEvent(name: Event.selectCalendar, metadata: [:])
                                self.viewModel.calendar()
                            }).padding(.top, -40)
                            Spacer()
                        }.frame(width: geometry.size.width * 0.333)
                        VStack {
                            Spacer()
                            if self.viewModel.isUpdatable {
                                PrescriptionButtonView(iconName: "square.and.pencil", action: {
                                    self.viewModel.update()
                                }).padding(.top, -40)
                            }
                        }.frame(width: geometry.size.width * 0.333)
                        VStack {
                            if self.viewModel.medicineHasDoses {
                                PrescriptionButtonView(iconName: "list.dash", action: {
                                    AnalyticsManager.shared.logEvent(name: Event.selectDoseList, metadata: [:])
                                    self.viewModel.doseList()
                                }).padding(.top, -40)
                            }
                            Spacer()
                        }.frame(width: geometry.size.width * 0.333)
                    }.frame(height: geometry.size.height * 0.2)
                    Spacer()
                }
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
            MedicineHomePageView(medicine: prescription,
                                 isRemovingPrescription: .constant(false),
                                 curentPrescription: .constant(prescription), viewModel: viewModel)
        }

    }
}
