//
//  MessageView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    @State private var offset: CGFloat = -200.0
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text("first_prescription_title_msg_add".localized)
                    .foregroundColor(Color.white)
                    .font(Font.system(.headline).bold())
                Spacer()
            }.frame(height: 100)
                .background(Color.gray.opacity(0.3))
                .offset(x: 0.0, y: self.offset)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.5)) { self.offset = 000.0
                    }
            }
            Spacer()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
