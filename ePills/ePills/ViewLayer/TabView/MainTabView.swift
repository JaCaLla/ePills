//
//  HomeView.swift
//  ePills
//
//  Created by Javier Calatrava on 18/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @State private var selection = 1
    var body: some View {
         TabView(selection: $selection) {
             RedView()
                .tabItem {
                   //Image(systemName: "phone.fill")
                   Text("First Tab")
            }.tag(0)
            HomeView(viewModel: HomeVM())
                .tabItem {
                   //Image(systemName: "tv.fill")
                   Text("Second Tab")
            }.tag(1)
            GreenView()
               .tabItem {
                  //Image(systemName: "tv.fill")
                  Text("Third Tab")
            }.tag(2)
         }
         .font(.headline)
    }
}

struct RedView: View {
    var body: some View {
        Color.red
    }
}
struct BlueView: View {
    var body: some View {
        Color.blue
    }
}
struct GreenView: View {
    var body: some View {
        Color.green
    }
}


struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
