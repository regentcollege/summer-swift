import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // TODO: launch the plan tab if there is anything planned (and hasn't passed)
        if window?.rootViewController as? UITabBarController != nil {
            let tabBarController = window!.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 1 // Open the course tab
            tabBarController.tabBar.tintColor = Settings.Color.red
        }
        
        // DI is done in Services/SwinjectService.swift
        
        return true
    }
}
