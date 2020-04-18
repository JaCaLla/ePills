//
//  FirstPrescriptionView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct FirstPrescriptionView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            MessageView()
            AddPrescriptionView()
        }
    }
}

struct FirstPrescriptionView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            FirstPrescriptionView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

            FirstPrescriptionView()
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
        }
    }
}
