//
//  ViewController.swift
//  AVManager
//
//  Created by Nattapong Unaregul on 5/31/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let avManager : AVManager = AVManager()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        avManager.prepareVideo(path: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")
//        avManager.presentAndPlay(onViewController:self)
    }

    @IBAction func presentAV(_ sender: Any) {
        avManager.prepareVideo(path: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")
        avManager.presentAndPlay(onViewController:self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

