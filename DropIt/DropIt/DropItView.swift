//
//  DropItView.swift
//  DropIt
//
//  Created by Vernsu on 16/9/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class DropItView: UIView , UIDynamicAnimatorDelegate{

    

    //没有完全初始化之前不能访问self，所以要惰性
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    
    }()

    
    private let dropBehavior = FallingObjectBehavior()
    
    //动画开关,默认是关闭的，当view出现后才打开
    var animating:Bool = false{
        didSet{ 
            if animating {
                animator.addBehavior(dropBehavior)
            }else{
                animator.removeBehavior(dropBehavior)

            }
        }
    }
    
    //列数
    private let dropsPerRow = 10
    
    private var dropSize: CGSize{
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    
    func addDrop(){
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        //如此，就有了加速度动画
        dropBehavior.addItem(drop)
        
        
    }
    
    // MARK: Remove Completed Row
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    
    private func removeCompletedRow()
    {
        var dropsToRemove = [UIView]()
        
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropsPerRow {
                if let hitView = hitTest(hitTestRect.mid) where hitView.superview == self {
                    dropsFound.append(hitView)
                } else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(drop)
            drop.removeFromSuperview()
        }
    }
}
