//
//  AppDelegate.swift
//  TimerDemo
//
//  Created by Mqch on 2021/4/15.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TimerViewController()
        let vm = TimerViewModel()
        vc.reactor = vm
        let rootNav = UINavigationController(rootViewController: vc)
        window?.rootViewController = rootNav
        window?.makeKeyAndVisible()
        return true
    }


}

