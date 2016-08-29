//
//  EmotionsViewController.swift
//  Faceit
//
//  Created by Vernsu on 16/8/26.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {


    private let emotionalFaces: Dictionary<String,FacialExpression> = [
        "angry" : FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Frown),
        "happy" : FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile),
        "worried" : FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk),
        "mischievious" : FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Grin)
    ]
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationvc = segue.destinationViewController
        if let navcon = destinationvc as? UINavigationController{
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let facevc = destinationvc as? FaceViewController{
            if let identifier = segue.identifier{
                if let expression = emotionalFaces[identifier]{
                    facevc.expression = expression
                    //使用sender
                    if let senderingButton = sender as? UIButton{
                        //等号两边都是optional
                        facevc.navigationItem.title = senderingButton.currentTitle
                    }
                }
            }
        }
    }


}
