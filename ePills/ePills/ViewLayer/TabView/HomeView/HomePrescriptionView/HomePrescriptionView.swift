//
//  HomePrescriptionView.swift
//  ePills
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct HomePrescriptionView: View {
     var coordinator: HomeCoordinator
    var body: some View {
        Text("Home prescription view")
            .background(Color(R.color.colorGray50.name))
    }
}

struct HomePrescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        HomePrescriptionView(coordinator: HomeCoordinator())
    }
}
