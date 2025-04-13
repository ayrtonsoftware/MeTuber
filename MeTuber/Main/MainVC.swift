//
//  ViewController.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//

import UIKit

class MainVC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let vc = WindowService.createVC(storyboard: "Videos", name: "Videos") else {
            // Error
            return
        }
        self.pushViewController(vc, animated: true)
    }
}

