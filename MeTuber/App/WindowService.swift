//
//  WIndowService.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//


import UIKit

public class WindowService: NSObject {
    public nonisolated(unsafe) var nc: UINavigationController?
        
    public static func createVC(storyboard: String, name: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        return vc
    }
    
    @MainActor
    public func push(storyboard: String, name: String) -> UIViewController?
    {
        if let vc = WindowService.createVC(storyboard: storyboard, name: name),
           let nc = self.nc {
            nc.pushViewController(vc, animated: true)
            return vc
        }
        return nil
    }
}
