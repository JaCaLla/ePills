//
//  SelectorCell.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct SelectorCell<T:Identifiable & CustomStringConvertible & Equatable>: View {
    @Binding var presentingModal: Bool
    @Binding var selectedIntervalIndex: T
    @State var hours: [T]
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("ColorGray50Semi"))
               // .opacity(0.15)
                .frame(height: 40)
            Button(action: { self.presentingModal = true },
                   label: {
                       HStack {
                        Text("\(self.selectedIntervalIndex.description)")
                            .padding(.leading)
                           Spacer()
                       }
                   }).foregroundColor(Color("ColorWhite"))
                .sheet(isPresented: $presentingModal) {
                    ModalView(presentedAsModal: self.$presentingModal,
                              selectedItem: self.$selectedIntervalIndex,
                              items: self.$hours)
            }.padding(.horizontal, 5)
        }.padding(.horizontal, 15)
    }
}

struct ModalView<T:Identifiable & CustomStringConvertible & Equatable>: View {

    @Binding var presentedAsModal: Bool
    @Binding var selectedItem: T
    @Binding var items: [T]

    var body: some View {
        ZStack {
            // BackgroundView()
            VStack {
                HStack {
                    Text("Select dose interval").font(.headline)
                    Spacer()
                    Button(action: {
                        self.presentedAsModal = false
                    }, label: {
                        Image(systemName: "xmark")
                    }).font(.body)
                }.padding(.top)
                    .padding(.horizontal)
                List(self.items) { item in
                    HStack {
                        Button(action: {
                            // Save the object into a global store to be used later on
                            self.selectedItem = item
                            // Present new view
                            self.presentedAsModal = false
                        }) {
                            //  Text(value: item)
                            Text(item.description)
                        }

                        Spacer()
                        if item == self.selectedItem {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("ColorGreen"))
                        }
                    }.font(.body)
                }.listStyle(GroupedListStyle())
            }
        } .foregroundColor(Color("ColorBlack"))
    }
}

struct SelectorCell_Previews: PreviewProvider {
    static var previews: some View {
        SelectorCell(presentingModal: .constant(false),
                     selectedIntervalIndex: .constant(Interval(secs: 8 * 3600, label: "8 Hours")),
                     hours:[])
    }
}
