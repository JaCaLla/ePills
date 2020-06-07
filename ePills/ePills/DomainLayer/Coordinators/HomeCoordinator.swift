//
//  HomeCoordinator.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftUI
import Combine

protocol HomeCoordinatorProtocol {
    func presentPrescriptionForm(interactor: MedicineInteractorProtocol, medicine: Medicine?)
    func presentCalendar(interactor: MedicineInteractorProtocol, medicine: Medicine)
     func presentDoseList(interactor: MedicineInteractorProtocol, medicine: Medicine)
    func replaceByFirstPrescription(interactor: MedicineInteractorProtocol)
}

public final class HomeCoordinator {

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()
    private var cancellable = Set<AnyCancellable>()

    private var onDismissIssueSubscription = Set<AnyCancellable>()

    func start() -> UIViewController {
        
        let interactor = MedicineInteractor(dataManager: DataManager.shared)
        navitationController.viewControllers = [getHomePrescriptionVC(interactor: interactor)]
        return navitationController
    }

    func getHomePrescriptionVC(interactor: MedicineInteractorProtocol) -> UIViewController {
        let homePrescriptionVM = HomePrescriptionVM(interactor: interactor, homeCoordinator: self)
        let homePrescriptionView = HomePrescriptionView(viewModel: homePrescriptionVM)
        let homePrescriptionVC = HomePrescriptionVC(rootView: homePrescriptionView)
       // homePrescriptionVC.title = "_Home2"
        homePrescriptionVC.tabBarItem = UITabBarItem(title: R.string.localizable.home_title.key.localized,
                                                     image: UIImage(systemName: "plus.rectangle"),
                                                     tag: 0)
        return homePrescriptionVC
    }

}

extension HomeCoordinator: HomeCoordinatorProtocol {
    func presentPrescriptionForm(interactor: MedicineInteractorProtocol, medicine: Medicine?) {
        let prescriptionFormVM = PrescriptionFormVM(interactor: interactor, medicine: medicine)
        prescriptionFormVM.onDismissPublisher.sink {
            self.navitationController.popViewController(animated: true)
        }.store(in: &onDismissIssueSubscription)
        let prescriptionFormView = PrescriptionFormView(viewModel: prescriptionFormVM)
        let prescriptionFormVC = PrescriptionFormVC(rootView: prescriptionFormView)
        prescriptionFormVC.hidesBottomBarWhenPushed = true

        self.navitationController.pushViewController(prescriptionFormVC, animated: true)
    }
    
    func presentCalendar(interactor: MedicineInteractorProtocol, medicine: Medicine) {
        #if true
        let mecicineCalendarVM = MedicineCalendarVM(medicine: medicine)
        let medicineCalendarView = MedicineCalendarView(viewModel: mecicineCalendarVM)
        let medicineCalendarVC = MedicineCalendarVC(rootView: medicineCalendarView)
        
        self.navitationController.pushViewController(medicineCalendarVC, animated: true)
        #else
        pastYesterdayStartedMedicineCycle(days: 9) { medicine, timeManager in
            let mecicineCalendarVM = MedicineCalendarVM(medicine: medicine, timeManager: timeManager)
                let medicineCalendarView = MedicineCalendarView(viewModel: mecicineCalendarVM)
                let medicineCalendarVC = MedicineCalendarVC(rootView: medicineCalendarView)
                
                self.navitationController.pushViewController(medicineCalendarVC, animated: true)
        }
        #endif
    }
    
    func presentDoseList(interactor: MedicineInteractorProtocol, medicine: Medicine) {
        
        let doseListVM = DoseListVM(medicine: medicine)
        let doseListView = DoseListView(viewModel: doseListVM)
        let doseListVC = DoseListVC(rootView: doseListView)
        self.navitationController.pushViewController(doseListVC, animated: true)
    }

    func replaceByFirstPrescription(interactor: MedicineInteractorProtocol) {
        let firstPresciptionCoordinator = FirstPresciptionCoordinator()
        firstPresciptionCoordinator.navitationController = self.navitationController
        firstPresciptionCoordinator.onFinishedPublisher.sink { _ in
            self.navitationController.viewControllers = [self.getHomePrescriptionVC(interactor: interactor)]
        }.store(in: &cancellable)
        let rootViewController = firstPresciptionCoordinator.start(navigationController: false)
        rootViewController.modalTransitionStyle = .crossDissolve
        self.navitationController.viewControllers = [rootViewController]
    }
}

private var cancellables = Set<AnyCancellable>()
func pastMedicineCycle(onComplete: @escaping (Medicine, TimeManagerProtocol) -> Void) {
    DataManager.shared.reset()
    let dataManager = DataManager.shared
    let interactor = MedicineInteractor(dataManager: dataManager)
    let timeManager = TimeManager()

    let medicine = Medicine(name: "a",
                            unitsBox: 10,
                            intervalSecs: 3600 * 24,
                            unitsDose: 1)
    guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { return }

    timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
    interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
    let suscripiton = interactor.getMedicinesPublisher()

              suscripiton.sink(receiveCompletion: { completion in
                 return
              }, receiveValue: { someValue in
                guard let medicine = someValue.first else { return }
                
                onComplete(medicine,timeManager)
                //  asyncExpectation.fulfill()
              }).store(in: &cancellables)
          interactor.flushMedicines()
    
}

func startMedicineCycle(onComplete: @escaping (Medicine, TimeManagerProtocol) -> Void) {
    DataManager.shared.reset()
    let dataManager = DataManager.shared
    let interactor = MedicineInteractor(dataManager: dataManager)
    let timeManager = TimeManager()

    let medicine = Medicine(name: "a",
                            unitsBox: 10,
                            intervalSecs: 3600 * 24,
                            unitsDose: 1)
    guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { return }

    timeManager.setInjectedDate(date: Date()) //Today
    interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
    let suscripiton = interactor.getMedicinesPublisher()

              suscripiton.sink(receiveCompletion: { completion in
                 return
              }, receiveValue: { someValue in
                guard let medicine = someValue.first else { return }
                
                onComplete(medicine,timeManager)
              }).store(in: &cancellables)
          interactor.flushMedicines()
    
}

func pastYesterdayStartedMedicineCycle(days: Int, onComplete: @escaping (Medicine, TimeManagerProtocol) -> Void) {
    DataManager.shared.reset()
    let dataManager = DataManager.shared
    let interactor = MedicineInteractor(dataManager: dataManager)
    let timeManager = TimeManager()

    let medicine = Medicine(name: "a",
                            unitsBox: 10,
                            intervalSecs: 3600 * 24,
                            unitsDose: 1)
    guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { return }

    timeManager.setInjectedDate(date: Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(3600 * 24 * days))) //Yesterday
    interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
    let suscripiton = interactor.getMedicinesPublisher()

              suscripiton.sink(receiveCompletion: { completion in
                 return
              }, receiveValue: { someValue in
                guard let medicine = someValue.first else { return }
                
                onComplete(medicine,timeManager)
                //  asyncExpectation.fulfill()
              }).store(in: &cancellables)
          interactor.flushMedicines()
    
}

func startMedicineMonoCycle(onComplete: @escaping (Medicine, TimeManagerProtocol) -> Void) {
    DataManager.shared.reset()
    let dataManager = DataManager.shared
    let interactor = MedicineInteractor(dataManager: dataManager)
    let timeManager = TimeManager()

    let medicine = Medicine(name: "a",
                            unitsBox: 1,
                            intervalSecs: 3600 * 24,
                            unitsDose: 1)
    guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { return }

    timeManager.setInjectedDate(date: Date()) //Today
    interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        
    let suscripiton = interactor.getMedicinesPublisher()

              suscripiton.sink(receiveCompletion: { completion in
                 return
              }, receiveValue: { someValue in
                guard let medicine = someValue.first else { return }
                
                onComplete(medicine,timeManager)
                //  asyncExpectation.fulfill()
              }).store(in: &cancellables)
          interactor.flushMedicines()
    
}

func pastMedicineMonoCycle(onComplete: @escaping (Medicine, TimeManagerProtocol) -> Void) {
    DataManager.shared.reset()
       let dataManager = DataManager.shared
       let interactor = MedicineInteractor(dataManager: dataManager)
       let timeManager = TimeManager()
    timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
       let medicine = Medicine(name: "a",
                               unitsBox: 1,
                               intervalSecs: 3600 * 24,
                               unitsDose: 1)
       guard let createdMedicine = interactor.add(medicine: medicine, timeManager: timeManager) else { return }

       timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
       interactor.takeDose(medicine: createdMedicine, timeManager: timeManager)
           
       let suscripiton = interactor.getMedicinesPublisher()

                 suscripiton.sink(receiveCompletion: { completion in
                    return
                 }, receiveValue: { someValue in
                   guard let medicine = someValue.first else { return }
                   
                   onComplete(medicine,timeManager)
                   //  asyncExpectation.fulfill()
                 }).store(in: &cancellables)
             interactor.flushMedicines()
    
}
