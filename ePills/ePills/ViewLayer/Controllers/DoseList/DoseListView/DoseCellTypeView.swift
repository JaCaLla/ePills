//
//  DoseCellTypeView.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct DoseCellTypeView: View {
    var doseCellViewModel: DoseCellViewModel
    weak var selectionLayer: CAShapeLayer!

    struct Constants {
        static let viewWidth: CGFloat = 45
    }

    init(doseCellViewModel: DoseCellViewModel) {
        self.doseCellViewModel = doseCellViewModel
    }

    var body: some View {
        ZStack {
            if self.doseCellViewModel.doseCellType == .endToday ||
                self.doseCellViewModel.doseCellType == .endPast {
                VerticalStripeMidBottomShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth)
                RoundedShape()
                    .fill(Color(self.doseCellViewModel.doseCellType == .endToday ?
                        R.color.colorBlueLight.name : R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth, height: Constants.viewWidth)
            } else if self.doseCellViewModel.doseCellType == .startPast {
                VerticalStripeBottomRoundedShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth)
                RoundedShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth, height: Constants.viewWidth)
            } else if self.doseCellViewModel.doseCellType == .middle {
                VerticalStripeShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth)
                RoundedShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth, height: Constants.viewWidth)
            } else if self.doseCellViewModel.doseCellType == .monoCycle {
                RoundedShape()
                    .fill(Color(R.color.colorBlue.name))
                    .frame(width: Constants.viewWidth, height: Constants.viewWidth)
            }
            Text(doseCellViewModel.doseOrder)
                .foregroundColor(Color(R.color.colorWhite.name))
                .fontWeight(.light)
        }.frame(width: Constants.viewWidth)
    }
}

struct RoundedShape: Shape {
    func path(in rect: CGRect) -> Path {
        let bezierPath = UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: [.topRight, .bottomRight, .topLeft, .bottomLeft],
                                      cornerRadii: CGSize(width: DoseCellTypeView.Constants.viewWidth / 2,
                                                          height: DoseCellTypeView.Constants.viewWidth / 2))
        return Path(bezierPath.cgPath)
    }
}

struct VerticalStripeMidBottomShape: Shape {

    func path(in rect: CGRect) -> Path {
        let bounds = CGRect(x: rect.minX,
                            y: rect.height / 2,
                            width: rect.width,
                            height: rect.height / 2)
        let bezierPath = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [],
                                      cornerRadii: CGSize(width: DoseCellTypeView.Constants.viewWidth / 2,
                                                          height: DoseCellTypeView.Constants.viewWidth / 2))
        return Path(bezierPath.cgPath)
    }
}

struct VerticalStripeShape: Shape {

    func path(in rect: CGRect) -> Path {
        let bezierPath = UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: [],
                                      cornerRadii: CGSize(width: DoseCellTypeView.Constants.viewWidth / 2,
                                                          height: DoseCellTypeView.Constants.viewWidth / 2))
        return Path(bezierPath.cgPath)
    }
}

struct VerticalStripeBottomRoundedShape: Shape {

    func path(in rect: CGRect) -> Path {
        let bounds = CGRect(x: rect.minX,
                            y: 0,
                            width: rect.width,
                            height: rect.height / 2)
        let bezierPath = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [],
                                      cornerRadii: CGSize(width: DoseCellTypeView.Constants.viewWidth / 2,
                                                          height: DoseCellTypeView.Constants.viewWidth / 2))
        return Path(bezierPath.cgPath)
    }
}

struct DoseCellTypeView_Previews: PreviewProvider {
    static var dose: DoseCellViewModel {
        return DoseCellViewModel(doseOrder: "5",
                                 day: "2",
                                 monthYear: "Junio - 2020",
                                 weekdayHHMM: "Viernes - 06:04",
                                 realOffset: "-1d 3h",
                                 realOffsetColorStr: "",
                                 doseCellType: .middle)
    }
    static var previews: some View {
        DoseCellTypeView(doseCellViewModel: DoseCellTypeView_Previews.dose)
    }
}
