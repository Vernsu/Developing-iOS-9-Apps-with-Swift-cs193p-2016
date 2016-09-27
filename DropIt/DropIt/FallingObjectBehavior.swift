//
//  FallingObjectBehavior.swift
//  DropIt
//
//  Created by Vernsu on 16/9/27.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class FallingObjectBehavior: UIDynamicBehavior {

    private let gravity = UIGravityBehavior()
    //我们可以用closure来初始化一个变量(需要显示申明type，因为需要检测返回值是否匹配)
    private let collider:UICollisionBehavior = {
        let collider = UICollisionBehavior()
        //自动的将reference view的bounds当做边界
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    private let itemBehavior:UIDynamicItemBehavior = {
       let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        //elasticity为1，代表碰撞（Collision）没有能量损失，相互反弹
        dib.elasticity = 0.75
        return dib
    }()
    
    
    func addBarrier(path: UIBezierPath, named name:String){
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    //我们创建了一个DynamicBehavior子类，显然，我们应该写初始化方法,init不需要写func关键字
    override  init() {
        //在你写的代码之前，无论如何都应该call super.init()
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(item: UIDynamicItem){
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem){
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
}
