//
//  BlinkingFaceViewController.swift
//  Faceit
//
//  Created by Vernsu on 16/9/23.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class BlinkingFaceViewController: FaceViewController {

    var blinking:Bool = false{
        didSet{
            startBlink()
        }
    }
    private struct BlinkRate{
        static let ClosedDuration = 0.4
        static let OpenDuration = 2.5
    }
    
    func  startBlink(){
        if blinking {
              faceView.eyesOpen = false
              NSTimer.scheduledTimerWithTimeInterval(
                BlinkRate.ClosedDuration,
                target: self,
                selector: #selector(BlinkingFaceViewController.endBlink),
                userInfo: nil,
                repeats: false
            )
        }
    }
     func endBlink(){
        faceView.eyesOpen = true
        NSTimer.scheduledTimerWithTimeInterval(
            BlinkRate.OpenDuration,
            target: self,
            selector: #selector(BlinkingFaceViewController.startBlink),
            userInfo: nil,
            repeats: false
        )
    
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        blinking = true
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        blinking = false
    }
}
