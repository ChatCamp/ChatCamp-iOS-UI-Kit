//
//  UIStoryboard+ChatCamp.swift
//  ChatCamp Demo
//
//  Created by Tanmay Khandelwal on 11/02/18.
//  Copyright © 2018 iFlyLabs Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func home() -> UIStoryboard {
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    static func createChannel() -> UIStoryboard {
        let bundle = Bundle(for: CreateChannelViewController.self)
        return UIStoryboard(name: "CreateChannel", bundle: bundle)
    }
}
