import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if window?.rootViewController as? UITabBarController != nil {
            let tabBarController = window!.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 0 // Open today
            tabBarController.tabBar.tintColor = Settings.Color.red
        }
        
        // DI is done in Services/SwinjectService.swift
        
        return true
    }
}
