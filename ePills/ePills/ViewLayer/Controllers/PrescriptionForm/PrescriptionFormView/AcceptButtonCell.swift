//
//  AcceptButtonCell.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct AcceptButtonCell: View {
    var action:() -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("ColorWhite"))
                .frame(height:40)
            .onTapGesture {
                self.action()
                                }
            Image(systemName: "plus.rectangle")
                .font(Font.system(size: 30).bold())
                .foregroundColor(Color.gray)
            //
        }.padding(.horizontal, 15)
            .padding(.top,30)
    }
    
    
}

struct AcceptButtonCell_Previews: PreviewProvider {
    static var previews: some View {
        AcceptButtonCell(action: { })
    }
}
