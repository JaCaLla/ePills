//
//  AcceptButtonCell.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct AcceptButtonCell: View {
    @Binding var medicine: Medicine?
    var action:() -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("ColorWhite"))
                .frame(height:40)
            .onTapGesture {
                self.action()
                                }
            Image(systemName: self.medicine == nil ? "plus.rectangle" : "square.and.pencil")
                .font(Font.system(size: 30).bold())
                .foregroundColor(Color.gray)
            //
        }.padding(.horizontal, 15)
            .padding(.top,30)
    }
    init(medicine:Binding<Medicine?>, action:@escaping () -> Void) {
        self._medicine = medicine
        self.action = action
    }
}

struct AcceptButtonCell_Previews: PreviewProvider {
    static var previews: some View {
        AcceptButtonCell(medicine: .constant(nil), action: { })
    }
}
