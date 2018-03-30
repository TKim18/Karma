
import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let APP_ID = "4E2E1A3D-FFCD-0343-FF47-1C589EC9B700"
    let API_Key = "FA7EA74D-684C-9B00-FF57-36FE9F512200"
    
    var backendless = Backendless.sharedInstance()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        backendless?.initApp(APP_ID, apiKey:API_Key)
        backendless?.userService.setStayLoggedIn(true)
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Configure navigation and tab bar appearance
        configureScheme()
        
        // Automatically login when device is logged in
        // autoLogin()
        
        return true
    }
    
    func configureScheme() {
        // Sets the universal navigation bar color, tint color, and text color across the whole app
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.barTintColor = UIColor(rgb: 285398)
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        // Changes the selected tab bar icon to white
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    func autoLogin() {
        let userService = backendless!.userService
        if (userService?.isValidUserToken().boolValue)! {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "MainTab") as! UITabBarController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

