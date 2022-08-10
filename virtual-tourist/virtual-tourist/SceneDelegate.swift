//
//  SceneDelegate.swift
//  virtual-tourist
//
//  Created by RhaXiel on 5/8/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //let navigationController = window?.rootViewController as! UINavigationController
        //let mapView = navigationController.topViewController as! MapViewController
        //mapView.dataController  = (UIApplication.shared.delegate as? AppDelegate)?.dataController
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapView = navigationController.topViewController as! MapViewController
        mapView.dataController  = (UIApplication.shared.delegate as? AppDelegate)?.dataController
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        do{
            try (UIApplication.shared.delegate as? AppDelegate)?.dataController.save()
        } catch{
            print("Couldn't save you data! Sorry! :(. Details: \(error.localizedDescription)")
        }
        
    }


}

