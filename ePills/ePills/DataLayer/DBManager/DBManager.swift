//
//  DBManager.swift
//  seco
//
//  Created by Javier Calatrava on 28/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

protocol DBManagerProtocol {

}

// MARK: - Resetable
class DBManager {

    static let shared = DBManager()
    var thread = Thread.current
    var realm: Realm!

    private init() {
        setRealmHandlers()
    }

    // MARK: - Cycle
    func create(cycleDB: CycleDB, onComplete: @escaping () -> Void = {/* Default empty block */}) {
    }
    
    func get(id: Int, onComplete: @escaping (CycleDB) -> Void = { _ in /* Default empty block */}) {
    }
    
    func getCycles(onComplete: @escaping ([CycleDB]) -> Void = { _ in /* Default empty block */}) {
    }
    
    func update(cycleDB: CycleDB, onComplete: @escaping () -> Void = {/* Default empty block */}) {
    }
    
    func getCycles(medicineId:Int) -> [Cycle] {
        return []
    }
    
    // MARK: - Dose
    func create(doseDB: DoseDB, onComplete: @escaping () -> Void = {/* Default empty block */}) {
        self.resetHandlerIfNecessary()
        if let foundIssueDB = self.getDose(id: doseDB.id) {
           // self.rename(issueDB: foundIssueDB, newIssueDB: issueDB, onComplete:onComplete)
        } else {
            do {
                try realm.write({
                    self.realm.add(doseDB)
                    onComplete()
                })
            } catch {
                // handle error
            }
        }
    }
    
    func getDoses() -> Results<DoseDB> {
        self.resetHandlerIfNecessary()
        return realm.objects(DoseDB.self)
    }
    
    func getDoses(cycleId:Int) -> [DoseDB] {
        return []
    }
    
    func getDose(id:String) -> DoseDB? {
        return nil
    }
    
    
    
/*
    // MARK: - IssueDB
    func create(issueDB: PrescriptionDB, onComplete: @escaping () -> Void = {/* Default empty block */}) {
        self.resetHandlerIfNecessary()
        if let foundIssueDB = self.getIssue(route: issueDB.route) {
            self.rename(issueDB: foundIssueDB, newIssueDB: issueDB, onComplete:onComplete)
        } else {
            do {
                try realm.write({
                    self.realm.add(issueDB)
                    onComplete()
                })
            } catch {
                // handle error
            }
        }
    }

    func getIssues() -> Results<IssueDB> {

        self.resetHandlerIfNecessary()
        return realm.objects(IssueDB.self)
    }

    func getIssue(route: String) -> PrescriptionDB? {

        self.resetHandlerIfNecessary()
        guard let uwpFoundMachine = realm.objects(PrescriptionDB.self).filter("route = %@", route).first else {
            return nil
        }

        return uwpFoundMachine
    }

    // MARK: - Private/Internal

    func rename(issueDB: PrescriptionDB, newIssueDB: PrescriptionDB, onComplete: @escaping () -> Void) {
        self.resetHandlerIfNecessary()
        guard !(realm.objects(PrescriptionDB.self).isEmpty) else { return }
        do {
            try realm.write({
                issueDB.name = newIssueDB.name
                issueDB.surename = newIssueDB.surename
                issueDB.email = newIssueDB.email
                issueDB.timestamp = newIssueDB.timestamp
                issueDB.report = newIssueDB.report
                issueDB.phone = newIssueDB.phone
                onComplete()
            })
        } catch {
            // handle error
            onComplete()
        }
    }
     */
    func resetHandlerIfNecessary() {
        guard thread == Thread.current else {
            self.setRealmHandlers()
            thread = Thread.current
            return
        }
    }

    func setRealmHandlers() {
        do {
            if NSClassFromString("XCTest") != nil {
                realm = try Realm(configuration: RealmConfig.utest.configuration)
            } else {
                realm = try Realm(configuration: RealmConfig.main.configuration)
            }
        } catch {
            // handle error
            print("REALM ERROR: MIGRATION TO SECURED DDBB WAS NOT POSSIBLE!!!!")
        }
    }
}


// MARK: - Resetable
extension DBManager: Resetable {
    func reset() {

        self.resetHandlerIfNecessary()
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            // handle error
        }
    }
}

