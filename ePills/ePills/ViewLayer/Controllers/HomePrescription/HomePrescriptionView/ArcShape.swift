//
//  ArcShape.swift
//  ePills
//
//  Created by Javier Calatrava on 08/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import SwiftUI
import CoreGraphics
import UIKit

struct ArcShape: Shape {
    var width: CGFloat
    var height: CGFloat
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        
        let bezierPath = UIBezierPath()
        let endAngle = 360.0 * progress - 90.0
        bezierPath.addArc(withCenter: CGPoint(x: width / 2, y: height / 2),
                          radius: width / 2.8,
                          startAngle: CGFloat(-90 * Double.pi / 180),
                          endAngle: CGFloat(endAngle * Double.pi / 180),
                          clockwise: true)
        
        return Path(bezierPath.cgPath)
    }
}
