//
//  PrescriptionDetailView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct PrescriptionFormView: View {

    // MARK: - Public Attributes
    @ObservedObject var viewModel: PrescriptionFormVM

    init(viewModel: PrescriptionFormVM) {
        self.viewModel = viewModel
    }

    // MARK: - View

    let nameValidator: (String) -> (String?) = { value in
        guard !value.isEmpty else { return R.string.localizable.prescription_form_err_name_empty.key.localized }
        guard value.count > 4 else { return R.string.localizable.prescription_form_err_name_minimum.key.localized }
        guard value.count < 20 else { return R.string.localizable.prescription_form_err_name_maximum.key.localized }
        return nil
    }
    @State var isNameValid = FieldChecker() // validation state of username field

    let unitsBoxValidator: (String) -> (String?) = { value in
        guard !value.isEmpty else { return R.string.localizable.prescription_form_err_units_box_empty.key.localized }
        guard value.count < 99 else {
            return R.string.localizable.prescription_form_err_units_box_maximum.key.localized
        }
        return nil
    }
    @State var isUnitsBoxValid = FieldChecker()

    let unitsDoseValidator: (String) -> (String?) = { value in
        guard !value.isEmpty else { return R.string.localizable.prescription_form_err_units_dose_empty.key.localized }
        guard value.count < 99 else {
            return R.string.localizable.prescription_form_err_units_dose_maximum.key.localized
        }
        return nil
    }

    @State var isUnitsDoseValid = FieldChecker()
    @State var isDosificationValid = FieldChecker()

    @State var presentingModal = false

     @ObservedObject private var keyboard = KeyboardResponder()
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                PictureCell(medicine: $viewModel.medicine, pictureMedicine: $viewModel.medicinePicture)
                SectionFormView(name: R.string.localizable.prescription_form_section_medicine.key.localized)
                TextFieldWithValidatorCell(title: R.string.localizable.prescription_form_section_medicine_name.key.localized,
                                           value: $viewModel.name,
                                           checker: $isNameValid, validator: nameValidator)
                    .autocapitalization(.none)
                TextFieldWithValidatorCell(title: R.string.localizable.prescription_form_section_medicine_units_box.key.localized,
                                           value: $viewModel.unitsBox,
                                           checker: $isUnitsBoxValid,
                                           validator: unitsBoxValidator)
                    .keyboardType(.numberPad)
                SectionFormView(name: R.string.localizable.prescription_form_section_administration.key.localized)
                SelectorCell<Interval>(presentingModal: $presentingModal,
                                       selectedIntervalIndex: $viewModel.selectedIntervalIndex,
                                       hours: viewModel.getIntervals())
                TextFieldWithValidatorCell(title: R.string.localizable.prescription_form_section_medicine_units_box.key.localized,
                                           value: $viewModel.unitsDose,
                                           checker: $isUnitsDoseValid,
                                           validator: unitsDoseValidator)
                    .keyboardType(.numberPad)

                if isValidForm() {
                    AcceptButtonCell(medicine: $viewModel.medicine, action: {
                        self.viewModel.save()
                    })
                }
                Spacer()
            }.padding(.top, 20)
            .padding(.bottom, keyboard.currentHeight)
                .padding(.top, -keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
        }
            .navigationBarTitle(Text(viewModel.title()))
            .onAppear {
                AnalyticsManager.shared.logScreen(name: Screen.prescriptionForm, flow: nil)
        }.onTapGesture {
           UIApplication.shared.endEditing()
        }
    }

    func isValidForm() -> Bool {
        return isNameValid.valid &&
            isUnitsBoxValid.valid &&
            isUnitsDoseValid.valid &&
            isDosificationValid.valid
    }

}

struct PrescriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager.shared
        let interactor = MedicineInteractor(dataManager: dataManager)
        let viewModel = PrescriptionFormVM(interactor: interactor, medicine: nil)
        return PrescriptionFormView(viewModel: viewModel)
    }
}

struct SectionFormView: View {
    // MARK: - View
    var name: String
    var body: some View {
        VStack(alignment: .leading, content: {
            HStack {
                Text(self.name)
                    .font(.headline)
                    .foregroundColor(Color(R.color.colorWhite.name))
                Spacer()
            }.padding(.horizontal, 15)
                .padding(.vertical, 0)
        })
    }
}
