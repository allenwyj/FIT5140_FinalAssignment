//
//  AppDelegate.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var databaseController: DatabaseProtocol?
    var timer = Timer()
    var isSend = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UITabBar.appearance().tintColor = UIColor.init(red: 0/255, green: 139/255, blue: 255/255, alpha: 1)
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted: \(granted)")
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        FirebaseApp.configure()
        
        // if user has no auth, the controller won't be set up
        // once the user login/sighup databaseController is created.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.databaseController = FirebaseController()
            }
        }
        
        setTimerToCheckFirestore()
        
        return true
    }
    
    func setTimerToCheckFirestore() {
        // 0 is default, 1 is setting
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(checkAlertValue), userInfo: nil, repeats: true)
    }
    
    @objc func checkAlertValue(sender: Timer) {
        getAlertDataFromFirebase()
    }
    
    func getAlertDataFromFirebase() {
        let fieldName = "alert"
        let database = Firestore.firestore()
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        
        dbRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let status = document.data()![fieldName] as! String
                if  status == "stolen" && !self.isSend { // stolen but not send yet: send notification
                    self.postLocalNotifications(eventTitle: "Warning", eventContent: "Someone is in your car!")
                    self.isSend = true
                    print("+++++++++++++CAR STOLEN++++++++++++++")
                } else if status == "safe" && self.isSend { // it's safe, but isSend, reset the isSend but dont send the notification
                    self.isSend = false
                    print("is send: true, safety")
                } else {
                    print("status: \(status), isSend: \(self.isSend)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /**
     Reference from https://www.youtube.com/watch?feature=youtu.be&v=Q5xT_eEaqsQ&app=desktop
     For building notifications pop-up when the app is running at background
     **/
    func postLocalNotifications(eventTitle: String, eventContent: String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = eventContent
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("notification added")
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "" {
            // Do something when user click the notification
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var newData = false
        let fieldName = "alert"
        let database = Firestore.firestore()
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        
        dbRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let status = document.data()![fieldName] as! String
                if  status == "stolen" && !self.isSend { // stolen but not send yet: send notification
                    self.postLocalNotifications(eventTitle: "Warning", eventContent: "Someone is in your car!")
                    self.isSend = true
                    print("+++++++++++++CAR STOLEN++++++++++++++")
                    newData = true
                } else if status == "safe" && self.isSend { // it's safe, but isSend, reset the isSend but dont send the notification
                    self.isSend = false
                    print("is send: true, safety")
                } else {
                    print("status: \(status), isSend: \(self.isSend)")
                }
                completionHandler(newData ? .newData : .failed)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //setTimerToCheckFirestore()
        
        
        print("Go to background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FIT5140_FinalAssignment")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

