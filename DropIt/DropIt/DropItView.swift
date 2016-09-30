//
//  DropItView.swift
//  DropIt
//
//  Created by Vernsu on 16/9/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import CoreMotion
class DropItView: NamedBezierPathsView , UIDynamicAnimatorDelegate{

    

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
                updateRealGravity()
            }else{
                animator.removeBehavior(dropBehavior)

            }
        }
    }
    
    var realGravitt: Bool = false{
        didSet{
            updateRealGravity()
        }
    }
    
    private let motionManager = CMMotionManager()
    private func updateRealGravity(){
        if realGravitt{
            if motionManager.accelerometerAvailable && !motionManager.accelerometerActive{
                motionManager.accelerometerUpdateInterval = 0
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue())
                {[unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil{
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y{
                            switch UIDevice.currentDevice().orientation{
                            case .Portrait: dy = -dy
                            case .PortraitUpsideDown: break
                            case .LandscapeRight: swap(&dx,&dy)
                            case .LandscapeLeft: swap(&dx, &dy); dy = -dy
                            default:dx = 0;dy = 0;
                            }
                            
                            
                            
                            
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx:dx , dy: dy)
                        }
                    }else{
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }

            }
        }else{
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    //列数
    private let dropsPerRow = 10
    
    private var dropSize: CGSize{
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    
    private var lastDrop: UIView?
    func addDrop(){
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        //如此，就有了加速度动画
        dropBehavior.addItem(drop)
        lastDrop = drop
        
        
    }
    
    
    private var attachment: UIAttachmentBehavior?{
        willSet{
            if attachment != nil{
                animator.removeBehavior(attachment!)
                //删除字典中的元素
                bezierPaths[PathsNames.Attachment] = nil
            }
        }
        didSet{
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = {[unowned self] in
                    if let attachedDrop = self.attachment!.items.first as? UIView {
                        self.bezierPaths[PathsNames.Attachment] = UIBezierPath.lineFrom(self.attachment!.anchorPoint, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    func grabDrop(recognizer:UIPanGestureRecognizer){
        let gesturePoint = recognizer.locationInView(self)
        switch recognizer.state {
        case .Began:
            //这里确保lastView没有被消掉
            if let dropToAttachTo = lastDrop where dropToAttachTo.superview != nil{
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .Changed:
            attachment?.anchorPoint = gesturePoint
        default:
            attachment = nil
        }
    }
    
    
    private struct PathsNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    //需要在bounds已经存在后添加，并且当bounds变化时也变化
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalInRect: CGRect(center: bounds.mid, size: dropSize))
        dropBehavior.addBarrier(path, named: PathsNames.MiddleBarrier)
        //贝塞尔曲线的绘制要放在drawRect中
        bezierPaths[PathsNames.MiddleBarrier] = path
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
