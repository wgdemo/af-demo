import UIKit
import CoreData
import FirebaseCore
import AppsFlyerLib
import AppTrackingTransparency


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
    [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AppsFlyerLib.shared().appsFlyerDevKey = "Uue7RffFu9warvPDqiHZ7B"
        AppsFlyerLib.shared().appleAppID = "987637882"
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendForces"), name: UIApplication.didBecomeActiveNotification, object: nil)
        return true
    }

    @objc func sendForces() {
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
                    if (error != nil){
                        print(error ?? "")
                        return
                    } else {
                        print(dictionary ?? "")
                        return
                    }
                })
        if #available(iOS 14, *) {
              ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .denied:
                    break
                case .notDetermined:
                    break
                case .restricted:
                    break
                case .authorized:
                    break
                @unknown default:
                    fatalError("Invalid authorization status")
                }
              }
            }
        }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            if BrushTrackManager.shared.isForceBrushTrackManager{
                return .portrait
            }else{
                return .all
            }
        }

    func application(_ application: UIApplication, configurationForConnecting
    connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CourseCalc")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

