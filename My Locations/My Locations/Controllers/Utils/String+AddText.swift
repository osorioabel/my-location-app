//
//  String+AddText.swift
//  My Locations
//
//  Created by Abel Osorio on 2/18/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import Foundation

extension String{
    
    mutating func addText(text: String?,withSeparator separator: String = "") {
        
        if let text = text {
            if !isEmpty {
            self += separator
            }
            self += text
        }
    }
    
    
}