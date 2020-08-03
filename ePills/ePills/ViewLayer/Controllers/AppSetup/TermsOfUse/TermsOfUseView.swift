//
//  TermsOfUseView.swift
//  ePills
//
//  Created by Javier Calatrava on 19/07/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI
import Combine

struct Label: UIViewRepresentable {

    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

struct TermsOfUseView: View {
    @ObservedObject var viewmodel: TermsOfUseVM
    var body: some View {
        ZStack {
            // Text(viewmodel.strTemsOfUSe)
            VStack {

                TextWithAttributedString(attributedString: viewmodel.atrTermsOfUse)
                Image(R.image.glass.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200.0, height:200)
                Spacer()
            }.padding(.horizontal)
                .padding(.bottom, 300)

//            HStack {
//                Spacer()
//                Label {
//                  //  $0.attributedText = self.viewmodel.atrTermsOfUse
//                    $0.numberOfLines = 0
//                    $0.text = """
//                    akh kjsdh  k  hkshjkhkdshkj dsfhsk hdshh kjsdhk hsdkjk jshskjh
//                    skjh skjsa khjsak h khsdhkkh j hksakhds kh hkjsadkhjsd hkhk
//                    jsdhkjds hkjhkjsdjhk s hkkhj sdkh js hkjk hsjhk s hkdhkjsdhkk hjds kh kh hksh kshkh khj ksdhkj
//                    """
//                }
//                .frame(width: 300, height: 300, alignment: .center)
//                .border(Color.red)
//                Spacer()
//            }

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
