//
//  TextFieldWithValidatorCell.swift
//  ePills
//
//  Created by Javier Calatrava on 23/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: Validation Closure
struct FieldChecker {
    var errorMessage: String?
    var valid: Bool { self.errorMessage == nil }
}

// MARK: FieldValidator validate the value changes updating the FieldChecker
class FieldValidator<T>: ObservableObject where T: Hashable {

    typealias Validator = (T) -> String?

    @Binding private var bindValue: T
    @Binding private var checker: FieldChecker

    @Published var value: T {
        willSet { self.doValidate(newValue) }
        didSet { self.bindValue = self.value }
    }
    private let validator: Validator

    var isValid: Bool { self.checker.valid }
    var errorMessage: String? { self.checker.errorMessage }

    init(_ value: Binding<T>, checker: Binding<FieldChecker>, validator: @escaping Validator) {
        self.validator = validator
        self._bindValue = value
        self.value = value.wrappedValue
        self._checker = checker
    }

    func doValidate(_ newValue: T? = nil) -> Void {
        self.checker.errorMessage = (newValue != nil) ?
        self.validator(newValue!):
            self.validator(self.value)
    }

} // end class FieldValidator

struct TextFieldWithValidatorCell: View {
    // specialize validator for TestField ( T = String )
    typealias Validator = (String) -> String?

    var title: String?

    @ObservedObject var field: FieldValidator<String>

    init(title: String = "", value: Binding<String>, checker: Binding<FieldChecker>, validator: @escaping Validator) {
        self.title = title;
        self.field = FieldValidator(value, checker: checker, validator: validator)

    }

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color(R.color.colorGray50Semi.name))
                    .border(field.isValid ? Color.clear : Color.red)
                    .frame(height: 40)
                    .padding(.horizontal, 15)

                ZStack {
                    TextField(title ?? "", text: $field.value)
                    .foregroundColor(Color(R.color.colorWhite.name))
                        .padding(.all)
                        .onAppear { self.field.doValidate() }
                }.frame(height: 20)
                    .padding(.horizontal, 20)
            }
            if(!field.isValid) {
                Text(field.errorMessage ?? "")
                    .fontWeight(.light)
                    .font(.footnote)
                    .foregroundColor(Color.red)
            }
        }
    }
}
