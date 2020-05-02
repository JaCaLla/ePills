//
//  PrescriptionButtonView.swift
//  ePills
//
//  Created by Javier Calatrava on 02/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct PrescriptionButtonView: View {
    var iconName: String
    var action: () -> Void
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    ZStack {
                        EmptyView()
                    }.frame(width:  geometry.size.height * 0.8 , height: geometry.size.height * 0.8)
                        .background(Color(R.color.colorGray50Semi.name))
                        .cornerRadius(geometry.size.height * 0.5)
                    Image(systemName: self.iconName)
                        .font(Font.system(size: geometry.size.height * 0.4 ).bold())
                        .foregroundColor(Color.white)
                }.frame(width:  geometry.size.height * 0.8, height:  geometry.size.height * 0.8, alignment: .center)
                    .onTapGesture {
                        self.action()
                }
            }
        }
    }
}

struct PrescriptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionButtonView(iconName: "plus.rectangle", action: {
            print("todo")
        }).frame(width: 415, height: 100).border(Color.black)
    }
}
