//
//  FirstPrescriptionView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine
struct FirstPrescriptionView: View {

    // MARK: - Publishers
    var onAddFirstPrescriptionPublisher: AnyPublisher<Void, Never> {
        return onAddFirstPrescriptionSubject.eraseToAnyPublisher()
    }
    private var onAddFirstPrescriptionSubject = PassthroughSubject<Void, Never>()

    // MARK: - Public Attributes
    var coordinator: FirstPresciptionCoordinator?

    // MARK: - View
    @State var onAddFirstPrescription: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                BackgroundView()
                MessageView()
                AddPrescriptionView().onTapGesture {
                    self.onAddFirstPrescription = true
                }
                    .onDisappear() {
                        self.onAddFirstPrescription = false
                }
            }.navigationBarTitle(Text(R.string.localizable.first_prescription_title.key.localized))
            if onAddFirstPrescription {
                ZStack {
                    EmptyView()
                }.onAppear() {
                    self.onAddFirstPrescriptionSubject.send()
                }
            }
        }//.onAppear {
//            self.viewModel.fetchPrescriptions()
//        }
    }

    init ( coordinator: FirstPresciptionCoordinator = FirstPresciptionCoordinator()) {

        self.coordinator = coordinator
    }
}

struct FirstPrescriptionView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            FirstPrescriptionView( coordinator: FirstPresciptionCoordinator())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

            FirstPrescriptionView(coordinator: FirstPresciptionCoordinator())
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")

            FirstPrescriptionView( coordinator: FirstPresciptionCoordinator())
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
        }
    }
}
