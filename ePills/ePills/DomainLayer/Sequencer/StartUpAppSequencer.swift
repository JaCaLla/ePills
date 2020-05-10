//
//  StartUpAppSequencer.swift
//  vlng
//
//  Created by Javier Calatrava Llaveria on 21/05/2019.
//  Copyright © 2019 Javier Calatrava Llaveria. All rights reserved.
//


import Foundation
import UIKit

class  StartUpAppSequencer {
    fileprivate let operationQueue = OperationQueue()

    func start() {

        let presentMainAppOperation = PresentMainAppOperation()
        let requestNotificationPermissionOp = RequestNotificationPermissionOp()

        let operations = [requestNotificationPermissionOp,
                          presentMainAppOperation]

        // Add operation dependencies
        presentMainAppOperation.addDependency(requestNotificationPermissionOp)
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}
