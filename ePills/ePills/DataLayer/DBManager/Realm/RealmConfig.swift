//
//  RealmConfig.swift
//  seco
//
//  Created by Javier Calatrava on 28/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

struct DBFilename {
    static let regular = "default.realm"
}

enum RealmConfig {

    // MARK: - private configurations
    private static let mainConfig = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: 0,

        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
    }
    )
   
    private static let utestConfig = Realm.Configuration(fileURL: nil,
                                                         inMemoryIdentifier: "test",
                                                         syncConfiguration: nil,
                                                         encryptionKey: nil,
                                                         readOnly: false,
                                                         schemaVersion: 0,
                                                         migrationBlock: nil,
                                                         deleteRealmIfMigrationNeeded: true,
                                                         objectTypes: nil)

    // MARK: - enum cases
    case main
    case utest

    // MARK: - current configuration
    var configuration: Realm.Configuration {
        switch self {
        case .main:
            return RealmConfig.mainConfig
        case .utest:
            return RealmConfig.utestConfig
        }
    }
}
