//
//  DebugManager.swift
//  ePills
//
//  Created by Javier Calatrava on 21/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
#if !RELEASE
    import FLEX
#endif
import UIKit

// MARK: - Detect shake gesture

#if !RELEASE
    extension UIWindow {
        open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                FLEXManager.shared.showExplorer()
            }
        }
    }
#endif
