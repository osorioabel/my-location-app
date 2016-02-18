//
//  MyTabBarController.swift
//  My Locations
//
//  Created by Abel Osorio on 2/18/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
    return nil
    }

}
