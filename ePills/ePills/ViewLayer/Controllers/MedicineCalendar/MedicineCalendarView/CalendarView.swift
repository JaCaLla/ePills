//
//  CalendarView.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import Combine

struct CalendarView: UIViewRepresentable {
    @ObservedObject var viewModel: MedicineCalendarVM
  

    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let calendar: FSCalendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    struct Colors {
        static let today = UIColor(named: R.color.colorRed.name) ?? UIColor.black
        static let pastToday = UIColor(named: R.color.colorBlue.name) ?? UIColor.black
        static let future = UIColor(named: R.color.colorBlueLight.name) ?? UIColor.black
        static let titleCycle = UIColor(named: R.color.colorWhite.name) ?? UIColor.black
        static let titleCycleToday = UIColor(named: R.color.colorRed.name) ?? UIColor.black
        static let outOfCycle = UIColor(named: R.color.colorGray25.name) ?? UIColor.black
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: self.viewModel, calendar: calendar)
    }

    func makeUIView(context: Context) -> FSCalendar {
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "CalendarCell")
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        calendar.scrollDirection = .vertical
        calendar.pagingEnabled = false
        calendar.firstWeekday = 2

        viewModel.doseIntervals.forEach { date in
            self.calendar.select(date)
        }
        calendar.customizeCalenderAppearance()
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        //  uiView.text = text
    }

    class Coordinator: NSObject, FSCalendarDataSource, FSCalendarDelegate {
        var control: CalendarView
        private var viewModel: MedicineCalendarVM
        private var calendar: FSCalendar
        private var cancellables = Set<AnyCancellable>()

        init(_ control: CalendarView, viewModel: MedicineCalendarVM, calendar: FSCalendar) {
            self.control = control
            self.viewModel = viewModel
            self.calendar = calendar
            self.viewModel
                .onScrollToExpirationDateSubject
                .sink {
                    calendar.select(Date(), scrollToDate: true)
            }.store(in: &cancellables)
        }

        // MARK: - FSCalendarDataSource
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            guard let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCell", for: date, at: position) as? CalendarCell else {
                return FSCalendarCell()
            }
            cell.reset()
            return cell
        }

        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
            self.configure(cell: cell, for: date, at: position)
        }

        // MARK: - FSCalendarDelegate

        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return false
        }

        private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {

            let diyCell = (cell as! CalendarCell)
            diyCell.reset()

            diyCell.dateIsToday = control.gregorian.isDateInToday(date)
            let selectionType = viewModel.getSelectionCicleType(date: date,
                                                                isCurrentMonth: position == .current,
                                                                timeManager: TimeManager())
            diyCell.fillColor = selectionType.fillColor()
            diyCell.todayFillColor = selectionType.todayFillColor()
            diyCell.selectionType = selectionType
        }
    }
}

extension FSCalendar {
    func customizeCalenderAppearance() {
        self.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]

        //       self.appearance.headerTitleFont      = UIFont.systemFont(ofSize: 20.0) // UIFont.init(name: Fonts.BalloRegular, size: 18)
        //       self.appearance.weekdayFont          = UIFont.systemFont(ofSize: 18.0) //UIFont.init(name: Fonts.RalewayRegular, size: 16)
        self.appearance.titleFont = UIFont.systemFont(ofSize: 1, weight: .thin)//UIFont.systemFont(ofSize: 18.0)// UIFont.init(name: Fonts.RalewayRegular, size: 16)
//
        self.appearance.headerTitleColor = UIColor.white//CalendarView.Colors.outOfCycle//UIColor.darkGray
        self.appearance.weekdayTextColor = UIColor.white//CalendarView.Colors.outOfCycle
        self.appearance.titleDefaultColor = UIColor.red// CalendarView.Colors.outOfCycle

//        self.appearance.eventDefaultColor    = Colors.NavTitleColor
        self.appearance.selectionColor = UIColor.clear//UIColor.purple
//        self.appearance.titleSelectionColor  = Colors.NavTitleColor
        self.appearance.todayColor = CalendarView.Colors.today//UIColor.blue
//        self.appearance.todaySelectionColor  = Colors.purpleColor
//
//        self.appearance.headerMinimumDissolvedAlpha = 0.0 // Hide Left Right Month Name
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
