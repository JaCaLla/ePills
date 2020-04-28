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
    
    // MARK: - Publishers
    var onAddPrescriptionPublisher: AnyPublisher<Void, Never> {
        return onAddPrescriptionSubject.eraseToAnyPublisher()
    }
    private var onAddPrescriptionSubject = PassthroughSubject<Void, Never>()
    let pres1 = Prescription(name: "aaaa", unitsBox: 20, interval: Interval(hours: 8, label: "4444"), unitsDose: 1)
    let pres2 = Prescription(name: "bbbb", unitsBox: 20, interval: Interval(hours: 8, label: "4444"), unitsDose: 1)
    let pres3 = Prescription(name: "cccc", unitsBox: 20, interval: Interval(hours: 8, label: "4444"), unitsDose: 1)
    
    
     // MARK: - Public Attributes
    @ObservedObject var viewModel: HomePrescriptionVM = HomePrescriptionVM(interactor: PrescriptionInteractor(dataManager: DataManager.shared), coordinator: HomeCoordinator())
 
    @State var strArray:[Prescription] = []
    var body: some View {
        ZStack{
            BackgroundView()
            VStack {
                Image(systemName: "plus.rectangle")
                .font(Font.system(size: 60).bold())
                .foregroundColor(Color.white)
                    .onTapGesture {
                        self.viewModel.addPrescription()
                }
//                PageView([pres1,pres2,pres3].map {
//                    PrescriptionHomePageView(prescription: $0)
//                    })
//                    .frame(height: 250)
//                    .padding()
                
                PageView(strArray.map {
                    PrescriptionHomePageView(prescription: $0)
                    })
                    .frame(height: 250)
                    .padding()
                
//                PageView(self.viewModel.prescriptions.map {
//                    PrescriptionHomePageView(prescription: $0)
//
//                },currentPage: self.viewModel.prescriptions.count - 1)
//                    .frame(height: 250)
//                    .padding()
                Spacer()
            }.onAppear{
                self.strArray.append(Prescription(name: self.viewModel.prescriptions.last?.name ?? "xx", unitsBox: 20, interval: Interval(hours: 8, label: "4444"), unitsDose: 1))
                self.viewModel.prescriptions.forEach { presciption in
                    print("\(presciption.name)")
                }
                print("self.viewModel.prescriptions.count: \(self.viewModel.prescriptions.count)")
            }
            
        }
    }
    
    init(viewModel: HomePrescriptionVM) {
        self.viewModel = viewModel
      //  self.viewModel.set(view: self)
    }
}

//struct HomePrescriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePrescriptionView(viewModel: HomePrescriptionVM(interactor: PrescriptionInteractor(dataManager: DataManager()), coordinator: HomeCoordinator()))
//    }
//}


struct PrescriptionHomePageView: View {
    var prescription: Prescription
    var body: some View {
        Text(prescription.name)
    }
    
    init(prescription: Prescription) {
        self.prescription = prescription
    }
}
