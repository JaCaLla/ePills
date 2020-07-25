//
//  MarkdownView.swift
//  ePills
//
//  Created by Javier Calatrava on 21/07/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct TextWithAttributedString: UIViewRepresentable {

    var attributedString: NSAttributedString = NSAttributedString(string: "HW!")

    func makeUIView(context: Context) -> ViewWithLabel {
        let view = ViewWithLabel(frame: .zero)
        return view
    }

    func updateUIView(_ uiView: ViewWithLabel, context: Context) {
        
        uiView.setString(attributedString)
    }
}

class ViewWithLabel : UIView {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(label)
        label.numberOfLines = 0
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setString(_ attributedString:NSAttributedString) {
        self.label.attributedText = attributedString
    }

    override var intrinsicContentSize: CGSize {
        label.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 50, height: 9999))
    }
}
