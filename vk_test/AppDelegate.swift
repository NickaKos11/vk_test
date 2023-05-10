//
//  AppDelegate.swift
//  vk_test
//
//  Created by Костина Вероника  on 04.05.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createWindow()
        return true
    }

    private func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVc = MainViewController()
        let navigationController = UINavigationController(rootViewController: rootVc)
        navigationController.modalPresentationStyle = .pageSheet
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}

