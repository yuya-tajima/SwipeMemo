//
//  AppDelegate.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/06/30.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureRealm()
        return true
    }

    private func configureRealm() {
        let configuration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                guard oldSchemaVersion < 1 else {
                    return
                }

                var memos: [(date: Date, object: MigrationObject)] = []
                migration.enumerateObjects(ofType: Memo.className()) { oldObject, newObject in
                    guard let oldObject = oldObject,
                          let newObject = newObject,
                          let date = oldObject["date"] as? Date else {
                        fatalError("Memo migration requires existing memo date data.")
                    }

                    memos.append((date, newObject))
                }

                memos
                    .sorted { $0.date > $1.date }
                    .enumerated()
                    .forEach { index, memo in
                        memo.object["displayOrder"] = index
                    }
            }
        )

        Realm.Configuration.defaultConfiguration = configuration
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
