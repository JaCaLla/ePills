//
//  MessageView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                Text("Press for adding your first prescription")
                    .foregroundColor(Color.white)
                .font(Font.system(.headline).bold())
                Spacer()
            }.frame(height: 100)
                .background(Color.gray.opacity(0.3))
            Spacer()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
