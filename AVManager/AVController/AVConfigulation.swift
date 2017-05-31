//
//  AVConfigulation.swift
//  AVManager
//
//  Created by Nattapong Unaregul on 5/31/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import Foundation
import UIKit

class AVConfigulation {
    fileprivate let screen = UIScreen.main.bounds
    var avScreenSmallFrame : CGRect
    var avScreenFullFrameOnPortrait : CGRect
    let ratioSmallSize : CGFloat = 0.45
    let defaultAnimationDuration : Double = 0.33
    var maximumVerticalSwipeThreshold : CGFloat!
    var managerScreenFullFrame : CGRect = UIScreen.main.bounds
    var managerScreenSmallFrame : CGRect = CGRect()
    
    let animationOptions : UIViewAnimationOptions = .curveEaseInOut
    
    var  mediaTimingFunction :CAMediaTimingFunction {
        get {
            var s : String = ""
            if animationOptions == .curveEaseInOut {
                s = kCAMediaTimingFunctionEaseInEaseOut
            }else if animationOptions == .curveEaseIn {
                s = kCAMediaTimingFunctionEaseIn
            }
            else if animationOptions == .curveEaseOut   {
                s = kCAMediaTimingFunctionEaseOut
            }else if animationOptions == .curveLinear {
                s  = kCAMediaTimingFunctionLinear
            }else {
                s = kCAMediaTimingFunctionEaseIn
            }
            return CAMediaTimingFunction(name: s)
        }
    }
    fileprivate let margin : CGFloat = 7
    init() {
        
        
        
        avScreenFullFrameOnPortrait = CGRect(x: 0, y: 0, width: screen.width, height: screen.width / 16 * 9)
        avScreenSmallFrame = CGRect(x: 0 , y: 0
            , width: avScreenFullFrameOnPortrait.width * ratioSmallSize, height: avScreenFullFrameOnPortrait.height * ratioSmallSize)
        managerScreenSmallFrame.size = CGSize(width: managerScreenFullFrame.width * ratioSmallSize, height: managerScreenFullFrame.height * ratioSmallSize)
        managerScreenSmallFrame.origin = CGPoint(x: screen.width - ( screen.width * ratioSmallSize ) - margin
            , y: screen.height - avScreenSmallFrame.height  - margin)
        maximumVerticalSwipeThreshold = screen.height - (avScreenFullFrameOnPortrait.height)
    }
}
