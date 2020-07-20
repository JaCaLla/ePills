//
//  TermsOfUseView.swift
//  ePills
//
//  Created by Javier Calatrava on 19/07/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct TermsOfUseView: View {
    @ObservedObject var viewmodel: TermsOfUseVM
    var body: some View {
        ZStack {
            Text(viewmodel.strTemsOfUSe)
        }.onAppear() {
            self.viewmodel.onPresented()
        }
        
    }
}

struct TermsOfUseView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfUseView(viewmodel: TermsOfUseVM())
    }
}
