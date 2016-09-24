//
//  EyeView.swift
//  FaceIt
//
//  Created by CS193p Instructor.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class EyeView: UIView
{
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }

    //我们一般把东西放到didSet中，除非did已经太晚了。
    //开头_,当我们既需要存储属性，又需要计算属性的时候这么做
    var _eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    
    
    var eyesOpen: Bool {
        get {
           return _eyesOpen
        }
        set {
            UIView.transitionWithView(
                self,
                duration: 0.2,
                options: [.TransitionFlipFromTop,.CurveLinear],
                animations: {//这儿有关于循环引用的问题吗？no，因为动画仅仅存在不到1秒。closure就失去作用了。
                    self._eyesOpen = newValue
                },
                completion: nil
            )
        }
    }

    override func drawRect(rect: CGRect)
    {
        var path: UIBezierPath!
        
        if eyesOpen {
            path = UIBezierPath(ovalInRect: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2))
        } else {
            path = UIBezierPath()
            path.moveToPoint(CGPoint(x: bounds.minX, y: bounds.midY))
            path.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
        }
        
        path.lineWidth = lineWidth
        color.setStroke()
        path.stroke()
    }
}
