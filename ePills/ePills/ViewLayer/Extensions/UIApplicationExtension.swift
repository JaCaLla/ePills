//
//  UIApplicationExtension.swift
//  vlng
//
//  Created by Javier Calatrava Llaveria on 21/05/2019.
//  Copyright © 2019 Javier Calatrava Llaveria. All rights reserved.
//

import UIKit


extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
extension UIApplication {

    class func present(viewController: UIViewController, animated: Bool, completion: (() -> Swift.Void)? = nil) {

        if var topController = UIApplication.shared.delegate?.window??.rootViewController {

            while (topController.presentedViewController) != nil {
                if let uwpPresentendViewController = topController.presentedViewController {
                    topController = uwpPresentendViewController
                }
            }

            topController.present(viewController, animated: animated, completion:completion)
        }
    }

    func hasNotch() -> Bool {
        if #available(iOS 11.0,  *) {
            guard let uwpDelegate = UIApplication.shared.delegate,
                let uwpWindow = uwpDelegate.window  as? UIWindow else {
                    return false
            }
            return uwpWindow.safeAreaInsets.top > 20
        }
        return false
    }

}
