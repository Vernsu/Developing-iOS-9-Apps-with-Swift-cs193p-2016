//
//  ViewController.swift
//  Faceit
//
//  Created by Vernsu on 16/8/23.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

    //我们用一个struct做model，struct的默认初始化方法要传入它定义的vars,任何一个var被改变，didSet方法都会被调用
    //但是当我们通过初始化方法设置值时，didSet不会被调用。因为我们的class还没有被完全初始化
    var expression = FacialExpression(eyes:.Closed , eyeBrows: .Relaxed, mouth: .Frown ){
        didSet{
            updateUI()
        }
    }
    //在MVC被创建，激活IBOutLet时，didSet会被调用,所以第一次跟新UI要靠他
    @IBOutlet weak var faceView: FaceView!{
        didSet{
            //在不涉及Model时，经常会将自定义View的手势事件target设置为View自己，方法自然要调用View的方法
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView, action: #selector(FaceView.changeScale(_:) )
                ))
            
            //不需要参数，因为在方法里获得手势也没有用
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector( FaceViewController.increaseHappiness)
            )
            happierSwipeGestureRecognizer.direction = .Up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector( FaceViewController.decreaseHappiness)
            )
            sadderSwipeGestureRecognizer.direction = .Down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            
            updateUI()
        }
    }
    
    @IBAction func toggleEyes(sender: UITapGestureRecognizer) {
        if sender.state == .Ended{
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            default:break
                
            }
        }
    }

    
    
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }
    
    func decreaseHappiness(){
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    private let mouthCurvatures = [FacialExpression.Mouth.Frown:-1.0, .Grin:0.5, .Smile:1.0, .Smirk:-0.5,.Neutral:0.0 ]
    private let eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed:0.5, .Furrowed:-0.5 ,.Normal:0.0  ]
    
    private func updateUI() {
        switch expression.eyes{
        case .Open: faceView.eyesOpen = true
        case .Closed: faceView.eyesOpen = false
        case .Squinting: faceView.eyesOpen = false
        }
        //字典通过key取值返回结果是optional，用?? 语法，在optional not set时设置默认值
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }

}

