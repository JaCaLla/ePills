//
//  DIYCalendarCell.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation
import FSCalendar

import UIKit


enum SelectionCicleType: Int {
    case none
    case dayOutOfMonth
    case startTodayLongCycle
    case startPastLongCycle
    case midFutureLongCycle
    case midTodayLongCycle
    case midPastLongCycle
    case endFutureLongCycle
    case endTodayLongCycle
    case endPastLongCycle
    case dayCycle
    case dayCycleToday
    case unknown

    func fillColor() -> UIColor {
        switch self {
        case .none: return UIColor.clear
        case .dayOutOfMonth: return UIColor.clear
        case .startTodayLongCycle: return CalendarView.Colors.future
        case .startPastLongCycle: return CalendarView.Colors.pastToday
        case .midFutureLongCycle: return CalendarView.Colors.future
        case .midTodayLongCycle: return CalendarView.Colors.future
        case .midPastLongCycle: return CalendarView.Colors.pastToday
        case .endFutureLongCycle: return CalendarView.Colors.future
        case .endTodayLongCycle: return CalendarView.Colors.pastToday
        case .endPastLongCycle: return CalendarView.Colors.pastToday
        case .dayCycle: return CalendarView.Colors.pastToday //v
        case .dayCycleToday: return CalendarView.Colors.pastToday //v
        case .unknown: return UIColor.clear
        }
    }
    
    func todayFillColor() -> UIColor {
        if self == .startTodayLongCycle ||
            self == .midTodayLongCycle ||
            self == .endTodayLongCycle {
             return CalendarView.Colors.pastToday
        } else {
           return UIColor.clear
        }
    }

    func titleLabelFont() -> UIFont {
        if self == .none ||
            self == .dayOutOfMonth {
            return UIFont.systemFont(ofSize: 16,weight: .thin)
        } else {
            return UIFont.systemFont(ofSize: 18,weight: .thin)
        }
    }

    func titleLabelTextColor() -> UIColor {
        switch self {
        case .none: return CalendarView.Colors.outOfCycle
        case .dayOutOfMonth: return UIColor.clear
        case .startTodayLongCycle: return CalendarView.Colors.titleCycleToday
        case .startPastLongCycle: return CalendarView.Colors.titleCycle
        case .midFutureLongCycle: return CalendarView.Colors.titleCycle
        case .midTodayLongCycle: return CalendarView.Colors.titleCycleToday
        case .midPastLongCycle: return CalendarView.Colors.titleCycle
        case .endFutureLongCycle: return CalendarView.Colors.titleCycle
        case .endTodayLongCycle: return CalendarView.Colors.titleCycleToday
        case .endPastLongCycle: return CalendarView.Colors.titleCycle
        case .dayCycle: return CalendarView.Colors.titleCycle
        case .dayCycleToday: return CalendarView.Colors.titleCycleToday
        case .unknown: return UIColor.clear
        }
    }
}


class CalendarCell: FSCalendarCell {

    //  weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    weak var todaySectionLayer: CAShapeLayer!
    var fillColor: UIColor = UIColor.green
    var todayFillColor: UIColor = UIColor.green
    let bottomMargin: CGFloat = 5.0
    var date: Date = Date()

    var selectionType: SelectionCicleType = .none {
        didSet {
            setNeedsLayout()
        }
    }

    func reset() {
        fillColor = UIColor.clear
        todayFillColor = UIColor.clear
        selectionType = .none
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = fillColor.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        let todaySectionLayer = CAShapeLayer()
        todaySectionLayer.fillColor = todayFillColor.cgColor
        todaySectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.contentView.layer.insertSublayer(todaySectionLayer, above: selectionLayer)
        self.selectionLayer = selectionLayer
        self.todaySectionLayer = todaySectionLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectionLayer.fillColor = fillColor.cgColor
        self.todaySectionLayer.fillColor = todayFillColor.cgColor
        self.selectionLayer.frame = self.contentView.bounds

        self.titleLabel.font = selectionType.titleLabelFont()
        self.titleLabel.textColor = selectionType.titleLabelTextColor()
        if selectionType == .startPastLongCycle ||
            selectionType == .startTodayLongCycle {
            self.selectionLayer.path = leftRoundedPath()
            if selectionType == .startTodayLongCycle {
                self.todaySectionLayer.path = roundedPath()
            }
        } else if selectionType == .midPastLongCycle ||
            selectionType == .midFutureLongCycle ||
            selectionType == .midTodayLongCycle {
            self.selectionLayer.path = rectPath()
            if selectionType == .midTodayLongCycle {
                self.todaySectionLayer.path = rightRoundedPath()
            }
        } else if selectionType == .endPastLongCycle ||
            selectionType == .endFutureLongCycle ||
            selectionType == .endTodayLongCycle {
            self.selectionLayer.path = rightRoundedPath()
        } else if selectionType == .dayCycleToday {
            self.selectionLayer.path = roundedPath()
        } else if selectionType == .dayCycle {
            self.selectionLayer.path = roundedPath()
        }
    }
    
    func rectPath() -> CGPath {
        let bounds = CGRect(x: selectionLayer.frame.origin.x,
                            y: selectionLayer.frame.origin.y + 0.0,
                            width: selectionLayer.frame.size.width,
                            height: selectionLayer.frame.size.height - 5.0)
        return  UIBezierPath(rect: bounds).cgPath
    }

    func leftRoundedPath() -> CGPath {
        let bounds = CGRect(x: selectionLayer.frame.origin.x + 10.0,
                            y: selectionLayer.frame.origin.y + 0.0,
                            width: selectionLayer.frame.size.width,
                            height: selectionLayer.frame.size.height - 5.0)
        return UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: [.topLeft, .bottomLeft],
                            cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2,
                                                height: self.selectionLayer.frame.width / 2)).cgPath
    }

    func rightRoundedPath() -> CGPath {
        let bounds = CGRect(x: selectionLayer.frame.origin.x,
                            y: selectionLayer.frame.origin.y + 0.0,
                            width: selectionLayer.frame.size.width,
                            height: selectionLayer.frame.size.height - 5.0)
        return UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: [.topRight, .bottomRight],
                            cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2,
                                                height: self.selectionLayer.frame.width / 2)).cgPath
    }

    func roundedPath() -> CGPath {
        let bounds = CGRect(x: selectionLayer.frame.origin.x + 10.0,
                            y: selectionLayer.frame.origin.y + 0.0,
                            width: selectionLayer.frame.size.width - 20.0,
                            height: selectionLayer.frame.size.height - 5.0)
        return UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: [.topRight, .bottomRight, .topLeft, .bottomLeft],
                            cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2,
                                                height: self.selectionLayer.frame.width / 2)).cgPath
    }

//    override func configureAppearance() {
//        super.configureAppearance()
//        // Override the build-in appearance configuration
//        if self.isPlaceholder {
//            self.eventIndicator.isHidden = true
//            self.titleLabel.textColor = UIColor.lightGray
//        }
//    }

}
