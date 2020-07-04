//
//  CalendarView.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Combine
import Foundation
import FSCalendar
import SwiftUI
import UIKit

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
                }
                .store(in: &cancellables)
        }

        // MARK: - FSCalendarDataSource
        func calendar(_ calendar: FSCalendar,
                      cellFor date: Date,
                      at position: FSCalendarMonthPosition) -> FSCalendarCell {
            guard let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCell",
                                                          for: date,
                                                          at: position) as? CalendarCell else {
                return FSCalendarCell()
            }
            cell.reset()
            return cell
        }

        func calendar(_ calendar: FSCalendar,
                      willDisplay cell: FSCalendarCell,
                      for date: Date,
                      at position: FSCalendarMonthPosition) {
            self.configure(cell: cell, for: date, at: position)
        }

        // MARK: - FSCalendarDelegate

        func calendar(_ calendar: FSCalendar,
                      shouldSelect date: Date,
                      at monthPosition: FSCalendarMonthPosition) -> Bool {
            return false
        }

        private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {

            guard let diyCell = cell as? CalendarCell else { return }
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
        self.appearance.titleFont = UIFont.systemFont(ofSize: 1, weight: .thin)
        self.appearance.weekdayTextColor = UIColor(named: R.color.colorWhite.name)
        self.appearance.titleDefaultColor = UIColor(named: R.color.colorRed.name)
        self.appearance.selectionColor = UIColor.clear
        self.appearance.todayColor = CalendarView.Colors.today
    }
}
