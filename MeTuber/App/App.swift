//
//  SceneDelegate.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//

import DependencyInjection
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DIContainer.register {
            Shared(DownloadManager() as IDownloadManager)
            Shared(JsonVideoManager() as IVideoManager)
        }
        return true
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIApplicationDelegate		 {
    var window: UIWindow?
    public static var sceneMap: [UIScene?:SceneDelegate] = [:]
    var ws = WindowService()
    
    static func scene(for view: UIView) -> UIScene? {
        guard let window = view.window else {
            return nil // The view is not attached to any window
        }
        return window.windowScene
    }
    
    static func getWindowService(view: UIView) -> WindowService? {
        if let scene = SceneDelegate.scene(for: view) {
            if let delegate = SceneDelegate.sceneMap[scene] {
                return delegate.ws
            }
        }
        return nil
    }

    func scene(_ scene: UIScene, willConnectTo
               session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        SceneDelegate.sceneMap[scene] = self
        self.window = UIWindow(windowScene: windowScene)
        window?.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "Main") as? MainVC {
            window?.rootViewController = vc
            ws.nc = vc
        }
    }
}

