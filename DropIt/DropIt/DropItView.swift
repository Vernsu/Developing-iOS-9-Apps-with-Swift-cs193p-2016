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
    //没有完全初始化之前不能访问self，所以要惰性
    private lazy var animator: UIDynamicAnimator =  UIDynamicAnimator(referenceView: self)
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
        
    }
}
