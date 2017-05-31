//
//  AVManager.swift
//  AVManager
//
//  Created by Nattapong Unaregul on 5/31/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import Foundation
import UIKit
enum AVSwipeState {
    case none,
    up,
    down,
    left,
    right
}
class AVManager : UIViewController{
    let screen = UIScreen.main.bounds
    let config = AVConfigulation()
    let bgColor = UIColor.blue
    let playerBgColor = UIColor.black
    var avController : AVPlayerController!
    let dragGestureRecognizer : UIPanGestureRecognizer = UIPanGestureRecognizer()
    var swipeState : AVSwipeState = .none
    var alphaSwipeVertical : CGFloat = 0
    let thresholdOnVertical : CGFloat = 0.5
    var isAnimiated : Bool = false
    init() {
        super.init(nibName: nil  , bundle: nil)
        self.view.frame.size = screen.size
        self.view.frame.origin = CGPoint(x: 0, y: screen.height)
        self.view.backgroundColor = bgColor
        avController = AVPlayerController(config: config)
        avController.delegate = self
        avController.containerView.backgroundColor = playerBgColor
        self.view.addSubview(avController.containerView)
        dragGestureRecognizer.addTarget(self, action: #selector(drag(sender:)))
        self.avController.containerView.addGestureRecognizer(dragGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRotate(notification:)), name: Notification.Name.UIDeviceOrientationDidChange  , object: nil)
    }
    func didRotate(notification : Notification){
        var transform : CGAffineTransform!
        var allowRotate : Bool = false
        if UIDevice.current.orientation.isLandscape && self.avController.screenState == .fullScreenPortrait {
            isAnimiated = true
            allowRotate = true
            if UIDevice.current.orientation == .landscapeLeft {
                transform = self.avController.containerView.transform
                    .rotated(by: CGFloat.pi / 2)
                    .translatedBy(x: screen.height / 2 - self.avController.containerView.center.y  , y: 0)
                    .scaledBy(x: config.managerScreenFullFrame.height / config.avScreenFullFrameOnPortrait.width
                        , y: config.managerScreenFullFrame.width / config.avScreenFullFrameOnPortrait.height)
            }else {
                transform = self.avController.containerView.transform
                    .rotated(by: -CGFloat.pi / 2)
                    .translatedBy(x: -screen.height / 2 + self.avController.containerView.center.y  , y: 0)
                    .scaledBy(x: config.managerScreenFullFrame.height / config.avScreenFullFrameOnPortrait.width
                        , y: config.managerScreenFullFrame.width / config.avScreenFullFrameOnPortrait.height)
            }
        }else if UIDevice.current.orientation.isPortrait && self.avController.screenState == .fullScreenLandscape {
            isAnimiated = true
            allowRotate = true
            transform = CGAffineTransform.identity
        }
        if allowRotate {
            UIView.animate(withDuration: config.defaultAnimationDuration, animations: {
                self.avController.containerView.transform = transform
            }, completion: { (isDone) in
                self.avController.screenState = (UIDevice.current.orientation.isPortrait ? .fullScreenPortrait : .fullScreenLandscape)
                self.isAnimiated = false
            })
        }
    }
    func drag(sender : UIPanGestureRecognizer) {
        let translatedPoint = sender.translation(in: avController.containerView)
        if sender.state == .ended || sender.state  == .cancelled  {
            if (swipeState == .up || swipeState == .down) {
                endVerticalMovingFrame()
            }
        }else if sender.state == .began {
            
            self.avController.hideControls()
        } else {
            updateSwipeState(translatedPoint: translatedPoint)
            updateMovingFrame(translatedPoint: translatedPoint)
        }
    }
    func updateSwipeState (translatedPoint p : CGPoint) {
        if avController.screenState == .fullScreenPortrait && p.y > 0 {
            swipeState = .down
        }else if avController.screenState  == .smallScreen {
            if p.y < 0 {
                swipeState = .up
            }else {
                swipeState = .none
            }
        }else {
            swipeState = .none
        }
    }
    func updateMovingFrame(translatedPoint p : CGPoint) {
        if swipeState == .up || swipeState == .down {
            updateVerticalMovingFrame(translatedPoint: p)
        }
    }
    func endVerticalMovingFrame(){
        var tagetAVRect : CGRect!
        var targetContainerRect : CGRect!
        var targetScreenState : AVScreenState!
        var targetBgColor : UIColor!
        if alphaSwipeVertical > thresholdOnVertical {
            tagetAVRect = config.avScreenSmallFrame
            targetContainerRect = config.managerScreenSmallFrame
            targetScreenState = .smallScreen
            targetBgColor = bgColor.withAlphaComponent(0)
        }else {
            tagetAVRect = config.avScreenFullFrameOnPortrait
            targetContainerRect = config.managerScreenFullFrame
            targetScreenState = .fullScreenPortrait
            targetBgColor = bgColor.withAlphaComponent(1)
            self.avController.showControls()
        }
        UIView.animate(withDuration: config.defaultAnimationDuration, delay: 0, options:config.animationOptions , animations: {
            self.avController.updateSizeVerticalMovingFrameOnEnd(targetAVRect: tagetAVRect, targetScreenState: targetScreenState)
            self.view.frame = targetContainerRect
            self.view.backgroundColor = targetBgColor
        }) { (isDone) in
            self.alphaSwipeVertical = 0
            self.swipeState = .none
        }
    }
    func updateVerticalMovingFrame(translatedPoint p : CGPoint) {
        alphaSwipeVertical = abs(p.y / config.maximumVerticalSwipeThreshold  )
        alphaSwipeVertical = min(max(0, alphaSwipeVertical),1)
        alphaSwipeVertical = swipeState == .up ? 1 - alphaSwipeVertical : alphaSwipeVertical
        let avSize = CGSize(width: config.avScreenFullFrameOnPortrait.width * (1 - (alphaSwipeVertical * (1-config.ratioSmallSize)))
            , height: config.avScreenFullFrameOnPortrait.height * (1 - (alphaSwipeVertical * (1-config.ratioSmallSize))))
        let managerSize = CGSize(width: config.managerScreenFullFrame.width * (1 - (alphaSwipeVertical * (1-config.ratioSmallSize)))
            , height: config.managerScreenFullFrame.height * (1 - (alphaSwipeVertical * (1-config.ratioSmallSize))))
        let managerOrigin = CGPoint(x: config.managerScreenSmallFrame.origin.x * alphaSwipeVertical
            , y: config.managerScreenSmallFrame.origin.y * alphaSwipeVertical)
        
        self.view.backgroundColor = bgColor.withAlphaComponent(1 - alphaSwipeVertical)
        self.view.frame.origin = managerOrigin
        self.view.frame.size = managerSize
        self.avController.updateSizeVerticalMovingFrameOnMoving(size: avSize)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func prepareVideo(path : String){
        self.avController.loadVideo(path: path)
    }
    func presentAndPlay(onViewController vc : UIViewController){
        vc.addChildViewController(self)
        vc.view.addSubview(self.view)
        UIView.animate(withDuration: config.defaultAnimationDuration, animations: {
            self.view.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { (isDone) in
            self.avController.play()
        })
    }
    
}
extension AVManager : AVPlayerControllerDelegate{
    func dismiss() {
        UIView.animate(withDuration: config.defaultAnimationDuration, animations: {
            self.view.frame.origin = CGPoint(x: 0, y: self.screen.height)
        }, completion: { (isDone) in
            self.avController.avPlayer = nil
            self.avController.layer = nil
        })
    }
}
