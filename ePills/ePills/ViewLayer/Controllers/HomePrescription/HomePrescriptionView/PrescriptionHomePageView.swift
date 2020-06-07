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
            ZStack {
                ArcShape(width: geometry.size.width, height: geometry.size.height, progress: self.viewModel.progressPercentage)
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
                        HStack {
                            if !self.viewModel.prescriptionTime.isEmpty {
                                Image(systemName: "alarm")
                                    .foregroundColor(Color.white)
                                    .font(Font.system(size: 20)
                                        .bold())
                                Text(self.viewModel.prescriptionTime)
                                    .font(Font.system(size: 20).bold())
                                    .foregroundColor(Color.white)
                            }
                        }
                        Spacer()
                    }.frame(height: geometry.size.height / 4)
                    HStack {
                        VStack {
                            Image(systemName: self.viewModel.prescriptionIcon)
                                .font(Font.system(size: 60).bold())
                                .foregroundColor(Color(self.viewModel.prescriptionColor))
                                .onTapGesture {
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
                            }
                        }
                    }.frame(height: geometry.size.height * 0.375)
                    HStack {
                        VStack {
                            PrescriptionButtonView(iconName: "calendar", action: {
                                self.viewModel.calendar()
                            })
                            Spacer()
                        }.frame(width: geometry.size.width * 0.333)
                        VStack {
                            Spacer()
                            if (self.viewModel.isUpdatable) {
                                PrescriptionButtonView(iconName: "square.and.pencil", action: {
                                    self.viewModel.update()
                                })
                            }
                        }.frame(width: geometry.size.width * 0.333)
                        VStack {
                            if self.viewModel.medicineHasDoses {
                                PrescriptionButtonView(iconName: "list.dash", action: {
                                    self.viewModel.doseList()
                                })
                            }
                            Spacer()
                        }.frame(width: geometry.size.width * 0.333)
                    }.frame(height: geometry.size.height / 4)
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

    struct ArcShape: Shape {
        var width: CGFloat
        var height: CGFloat
        var progress: Double

        func path(in rect: CGRect) -> Path {

            let bezierPath = UIBezierPath()
            let endAngle = 360.0 * progress - 90.0
            bezierPath.addArc(withCenter: CGPoint(x: width / 2, y: height / 2),
                              radius: width / 3,
                              startAngle: CGFloat(-90 * Double.pi / 180),
                              endAngle: CGFloat(endAngle * Double.pi / 180),
                              clockwise: true)

            return Path(bezierPath.cgPath)
        }
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
