//
//  PlayerController.swift
//  AVManager
//
//  Created by Nattapong Unaregul on 5/31/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum AVScreenState {
    case fullScreenPortrait,
    fullScreenLandscape,
    smallScreen
}
protocol AVPlayerControllerDelegate {
    func dismiss();
}
class AVPlayerController: NSObject {
    var screenState = AVScreenState.fullScreenPortrait
    let containerView = UIView()
    var avPlayer : AVPlayer?
    var layer : AVPlayerLayer?
    var config : AVConfigulation!
    var playerItemContext : UnsafeMutableRawPointer?
    let closeBtn : UIButton = UIButton()
    let marginFromEdge : CGFloat = 7
    var delegate : AVPlayerControllerDelegate?
    init(config : AVConfigulation) {
        super.init()
        self.config = config
        containerView.frame = self.config.avScreenFullFrameOnPortrait
        setControls()
    }
    func hideControls(){
        closeBtn.isHidden = true
    }
    func showControls(){
        closeBtn.isHidden = false
    }
    func setControls(){
        closeBtn.frame.size = CGSize(width: 50, height: 30)
        closeBtn.frame.origin = CGPoint(x: self.containerView.frame.width - 50 - marginFromEdge, y: marginFromEdge)
        closeBtn.setTitle("Close", for: UIControlState.normal)
        closeBtn.addTarget(self, action: #selector(self.dismiss) , for: UIControlEvents.touchUpInside)
        self.containerView.addSubview(closeBtn)
    }
    func dismiss(){
        self.avPlayer?.pause()
        delegate?.dismiss()
    }
    func updateSizeVerticalMovingFrameOnMoving(size : CGSize){
        self.containerView.frame.size =  size
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        CATransaction.setDisableActions(true)
        self.layer?.frame.size = size
        CATransaction.commit()
    }
    func updateSizeVerticalMovingFrameOnEnd(targetAVRect r1 : CGRect,targetScreenState s : AVScreenState){
        self.containerView.frame.size =  r1.size
        CATransaction.begin()
        CATransaction.setAnimationDuration(self.config.defaultAnimationDuration)
        CATransaction.setAnimationTimingFunction(self.config.mediaTimingFunction)
        self.layer?.frame.size = r1.size
        CATransaction.setCompletionBlock {
            self.screenState = s
        }
        CATransaction.commit()
    }
    func loadVideo(path : String){
        let url = URL(string: path)
        let asset = AVAsset(url: url!)
        let assetKeys = [
            "playable"
        ]
        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: assetKeys)
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        avPlayer = AVPlayer(playerItem: playerItem)
        layer = AVPlayerLayer(player: avPlayer)
        layer?.frame = self.config.avScreenFullFrameOnPortrait
        
        containerView.layer.insertSublayer(layer!, at: 0)
        
        
    }
    func play(){
        self.avPlayer?.play()
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                print("readyToPlay")
                break;
            case .failed:
                break;
            case .unknown:
                break;
            }
        }
    }
    
}
