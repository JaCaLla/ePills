//
//  AnalyticsManager.swift
//  ePills
//
//  Created by Javier Calatrava on 11/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

struct Screen {

    static let addFirstMedicine = "add_first_medicine"
    static let prescriptionForm = "prescription_form"
    static let currentPrescription = "current_prescription"
    static let setup = "setup"
    static let calendar = "calendar"
    static let doseList = "dose_list"
    static let home = "home"
}

struct ScreenFlow {

    static let firstMedicine = "first_medicine"
}

struct Event {

    static let addFirstMedicine = "add_first_medicine"
    static let addedMedicine = "add_medicine"
    static let removedMedicine = "removed_medicine"
    static let updatedMedicine = "updated_medicine"
    static let takeDose = "take_dose"
    static let takeLastDose = "take_last_dose"
    static let selectInterval = "select_interval"
    static let selectCalendar = "select_calendar"
    static let selectDoseList = "select_dose_list"
}

struct UserProperties {
    static let medicines = "medicines"
}

struct ParamEvent {
    static let duarionHours = "duration_hours"
}

protocol AnalyticsEngineProtocol {
    func logScreen(name: String, flow: String?)
    func logEvent(name: String, metadata: [String: Any])
    func setUser(property: String, value: String?)
}

class AnalyticsManager {

    static let shared = AnalyticsManager()

    // MARK: - Private attributes
    private var analyticsEngine: AnalyticsEngineProtocol?

    private init() { }

    func set(analyticsEngine: AnalyticsEngineProtocol) {
        self.analyticsEngine = analyticsEngine
    }
}

extension AnalyticsManager: AnalyticsEngineProtocol {
    func logScreen(name: String, flow: String?) {
        guard let engine = analyticsEngine else { return }
        engine.logScreen(name: name, flow: flow)
    }

    func logEvent(name: String, metadata: [String: Any]) {
        guard let engine = analyticsEngine else { return }
        engine.logEvent(name: name, metadata: metadata)
    }

    func setUser(property: String, value: String?) {
        guard let engine = analyticsEngine else { return }
        engine.setUser(property: property, value: value)
    }
}
