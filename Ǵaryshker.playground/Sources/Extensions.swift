//
//  Extensions.swift
//  G'aryshker
//
//  Created by Баубек on 2/28/20.
//  Copyright © 2020 BaubekZh. All rights reserved.
//

import Foundation
import UIKit
import ARKit

public extension Double {
    func degreesToRadians() -> CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}
public extension SCNNode {
    func pivotOnTopCenter() {
        let (_, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(0, max.y, 0)
    }
}

public extension AVPlayer {
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
        
    }
}
