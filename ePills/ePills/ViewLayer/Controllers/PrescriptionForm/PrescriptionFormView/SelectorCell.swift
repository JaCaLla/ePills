//
//  SelectorCell.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct SelectorCell<T: Identifiable & CustomStringConvertible & Equatable>: View {
    @Binding var presentingModal: Bool
    @Binding var selectedIntervalIndex: T
    @State var hours: [T]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(R.color.colorGray50Semi.name))
                .frame(height: 40)
            Button(action: { self.presentingModal = true },
                   label: {
                       HStack {
                           Text("\(self.selectedIntervalIndex.description)")
                               .padding(.leading)
                           Spacer()
                       }
                   }).foregroundColor(Color(R.color.colorWhite.name))
                .sheet(isPresented: $presentingModal) {
                    ModalView(presentedAsModal: self.$presentingModal,
                              selectedItem: self.$selectedIntervalIndex,
                              items: self.$hours)
                }
                .padding(.horizontal, 5)
        }.padding(.horizontal, 15)
    }
}

struct ModalView<T: Identifiable & CustomStringConvertible & Equatable>: View {

    @Binding var presentedAsModal: Bool
    @Binding var selectedItem: T
    @Binding var items: [T]

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(R.string.localizable.prescription_form_interval_list_title.key.localized).font(.headline)
                        .foregroundColor(Color(R.color.colorBlack.name))
                    Spacer()
                    Button(action: {
                        self.presentedAsModal = false
                    }, label: {
                        Image(systemName: "xmark").foregroundColor(Color(R.color.colorBlack.name))
                    }).font(.body)
                }.padding(.top)
                    .padding(.horizontal)
                List(self.items) { item in
                    HStack {
                        Button(action: {
                            self.selectedItem = item
                            self.presentedAsModal = false
                        })
                        {
                            Text(item.description)
                                .foregroundColor(Color(R.color.colorBlack.name))
                        }
                        Spacer()
                        if item == self.selectedItem {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(R.color.colorGreen.name))
                        }
                    }.font(.body)
                }.listStyle(GroupedListStyle())
            }
        }.foregroundColor(Color(R.color.colorBlack.name))
    }
}

struct SelectorCell_Previews: PreviewProvider {
    static var previews: some View {
        SelectorCell(presentingModal: .constant(false),
                     selectedIntervalIndex: .constant(Interval(secs: 8, label: "8 Hours")),
                     hours: [])
    }
}
