//
//  AddPrescriptionView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct AddPrescriptionView: View {
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    Text("")
                }.frame(width: 100, height: 100)
                    .background(Color.gray)
                    .opacity(0.3)
                    .cornerRadius(40.0)
                Image(systemName: "plus.rectangle")
                    .font(Font.system(size: 60).bold())
                    .foregroundColor(Color.white)
            }.padding(.all, 30.0)
        }
    }
}

struct AddPrescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AddPrescriptionView()
    }
}
