//
//  HomeView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeVM
    var body: some View {
        NavigationView {
            ZStack{
                BackgroundView()
                 if viewModel.isFirstPrescription {
                    FirstPrescriptionView()
                } else {
                    Text("Add First prescription")
                }
            }
            .navigationBarTitle("ePills")
            .navigationBarColor(UIColor(named:"ColorGreySemi"))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            HomeView(viewModel: HomeVM())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")

            HomeView(viewModel: HomeVM())
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
        }
    }
}
