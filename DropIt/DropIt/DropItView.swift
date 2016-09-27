//
//  DropItView.swift
//  DropIt
//
//  Created by Vernsu on 16/9/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class DropItView: UIView {

    
    private let gravity = UIGravityBehavior()
    //我们可以用closure来初始化一个变量(需要显示申明type，因为需要检测返回值是否匹配)
    private let collider:UICollisionBehavior = {
        let collider = UICollisionBehavior()
        //自动的将reference view的bounds当做边界
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    //没有完全初始化之前不能访问self，所以要惰性
    private lazy var animator: UIDynamicAnimator =  UIDynamicAnimator(referenceView: self)
  
    
    //动画开关,默认是关闭的，当view出现后才打开
    var animating:Bool = false{
        didSet{
            if animating {
                animator.addBehavior(gravity)
                animator.addBehavior(collider)
            }else{
                animator.removeBehavior(gravity)
                animator.addBehavior(collider)
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
        gravity.addItem(drop)
        collider.addItem(drop)
        
        
    }
}
