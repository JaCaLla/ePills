//
//  BackgroundView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image("background")
            .resizable()
            //.padding(-40.0)
            .scaledToFill()
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            BackgroundView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

            BackgroundView()
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
        }
    }
}
