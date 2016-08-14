//
//  AppDelegate.swift
//  Tesla
//
//  Created by Sergey Zenchenko on 8/9/16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: RootViewController())
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

