//
//  HomePrescriptionView.swift
//  ePills
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine
struct HomePrescriptionView: View {

    private var subscription = Set<AnyCancellable>()

    // MARK: - Public Attributes
    @ObservedObject var viewModel: HomePrescriptionVM = HomePrescriptionVM(interactor: MedicineInteractor(dataManager: DataManager.shared), homeCoordinator: HomeCoordinator())

    @State var isRemovingPrescription: Bool = false

    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                GeometryReader { geometry in
                    PageView(self.viewModel.medicines.map {
                        PrescriptionHomePageView(medicine: $0,
                                                 isRemovingPrescription: self.$isRemovingPrescription,
                                                 curentPrescription: self.$viewModel.currentPrescription,
                                                 viewModel: self.viewModel)
                    }, currentPage: self.$viewModel.currentPage)
                        .background(Color(R.color.colorGray50Semi.name))
                        .frame(height: geometry.size.height * 0.90)
                        .padding()
                    Spacer()
                }
            }.padding(.top, 20)
                .alert(isPresented: self.$isRemovingPrescription) {
                    Alert(title: Text(R.string.localizable.home_alert_title.key.localized),
                          message: Text(R.string.localizable.home_alert_message.key.localized),
                          primaryButton: .default (Text(R.string.localizable.home_alert_ok.key.localized)) {
                              self.viewModel.remove()
                          },
                          secondaryButton: .cancel()
                    ) }
        }.navigationBarItems(trailing:
            Button(action: {
                self.viewModel.addPrescription()
            })
        {
            Image(systemName: "plus.rectangle")
                .font(Font.system(size: 20).bold())
                .foregroundColor(Color(R.color.colorGray50.name))
        }
        ).navigationBarTitle(R.string.localizable.home_title.key.localized)
    }

    init(viewModel: HomePrescriptionVM) {
        self.viewModel = viewModel
    }
}

struct HomePrescriptionView_Previews: PreviewProvider {
    static var prescriptionInteractor: MedicineInteractor {
        let medicine = Medicine(name: "Clamoxyl 200mg", unitsBox: 20, intervalSecs: 8, unitsDose: 2)
        let dataManager: DataManager = DataManager.shared
        dataManager.add(medicine: medicine, timeManager: TimeManager())
        return MedicineInteractor(dataManager: dataManager)
    }

    static var previews: some View {

        HomePrescriptionView(viewModel: HomePrescriptionVM(interactor: HomePrescriptionView_Previews.prescriptionInteractor,
                                                           homeCoordinator: HomeCoordinator()))
    }
}
