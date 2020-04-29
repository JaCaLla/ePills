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

//    // MARK: - Publishers
//    var onAddPrescriptionPublisher: AnyPublisher<Void, Never> {
//        return onAddPrescriptionSubject.eraseToAnyPublisher()
//    }
//    private var onAddPrescriptionSubject = PassthroughSubject<Void, Never>()
private var subscription = Set<AnyCancellable>()

    // MARK: - Public Attributes
    @ObservedObject var viewModel: HomePrescriptionVM = HomePrescriptionVM(interactor: PrescriptionInteractor(dataManager: DataManager.shared), homeCoordinator: HomeCoordinator())

   
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Rectangle().fill().background(Color.yellow).frame(height: 20)
                PageView(self.viewModel.prescriptions.map {
                    PrescriptionHomePageView(prescription: $0,
                                             dosePrescription: self.$viewModel.dosePrescription)
                }).background(Color(R.color.colorGray50Semi.name))
                    .frame(height: 400)
                    
                    .padding()
                Spacer()
            }
        }.navigationBarItems(trailing:
            Button(action: {
                  self.viewModel.addPrescription()
            }) {
                Image(systemName: "plus.rectangle")
                    .font(Font.system(size: 20).bold())
                    .foregroundColor(Color(R.color.colorGray50.name))
            }
        ).navigationBarTitle("_Home")
    }

    init(viewModel: HomePrescriptionVM) {
        self.viewModel = viewModel
    }
}

struct HomePrescriptionView_Previews: PreviewProvider {
    static var prescriptionInteractor: PrescriptionInteractor {
        let prescription = Prescription(name: "Clamoxyl 200mg", unitsBox: 20, interval: Interval(hours: 8, label: "Every 8 hours"), unitsDose: 2)
        let dataManager: DataManager = DataManager.shared
        dataManager.add(prescription: prescription)
        return PrescriptionInteractor(dataManager: dataManager)
    }

    static var previews: some View {

        HomePrescriptionView(viewModel: HomePrescriptionVM(interactor: HomePrescriptionView_Previews.prescriptionInteractor,
                                                           homeCoordinator: HomeCoordinator()))
    }
}
