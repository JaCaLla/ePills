//
//  DoseListView.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct DoseListView: View {
    @ObservedObject var viewModel: DoseListVM
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DoseListView_Previews: PreviewProvider {
    static var viewModel: DoseListVM {
     let medicine = Medicine(name: "a",
                                      unitsBox: 10,
                                      intervalSecs: 8,
                                      unitsDose: 1)
          return  DoseListVM(medicine: medicine)
        }
        
    static var previews: some View {
        DoseListView(viewModel: DoseListView_Previews.viewModel)
    }
}

