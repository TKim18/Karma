
import UIKit
import UserNotifications
import Firebase
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Configure navigation and tab bar appearance
        configureScheme()
        
        Messaging.messaging().delegate = self
        DropDown.startListeningToKeyboard()
        
        // Request permission to enable push notifications
        enableNotifs(application)
        
        // Automatically login when device is logged in
        autoLogin()
        
        return true
    }
    
    func configureScheme() {
        // Sets the universal navigation bar color, tint color, and text color across the whole app
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.white //(rgb: 285398)
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
    }
    
    func enableNotifs(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func autoLogin() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                UserUtil.getCurrentProperty(key: Constants.User.Fields.circles) { prop in
                    if prop == nil {
                        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                        let controller = storyBoard.instantiateViewController(withIdentifier: "NoCircle")
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = controller
                        self.window?.makeKeyAndVisible()
                    } else {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyBoard.instantiateViewController(withIdentifier: "MainTab") as! UITabBarController
                        
                        let notifTab = controller.tabBar.items![1]
                        UserUtil.getNumAccepts() { number in
                            if let number = number as? Int {
                                if number != 0 {
                                    notifTab.badgeValue = String(describing: number)
                                }
                            }
                        }
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = controller
                        self.window?.makeKeyAndVisible()
                    }
                }
            } else {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let controller = storyBoard.instantiateViewController(withIdentifier: "LoginScreen")
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
            }
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        application.applicationIconBadgeNumber += 1
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let deviceToken = Messaging.messaging().fcmToken!
        Database.database().reference().child("devices/\(deviceToken)").setValue(true)
        
        print("Firebase registration token: \(fcmToken)")
    }
}

