//
//  PresentMainAppOperation.swift
//  vlng
//
//  Created by Javier Calatrava Llaveria on 21/05/2019.
//  Copyright © 2019 Javier Calatrava Llaveria. All rights reserved.
//

import Foundation
import UIKit

class PresentMainAppOperation: ConcurrentOperation {

    override init() {
        super.init()
    }

    override func main() {
        DispatchQueue.main.async {
              MainFlowCoordinator.shared.start()
            
            
              self.state = .finished
          }
    }
}
