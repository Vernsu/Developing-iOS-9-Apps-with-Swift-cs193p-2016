//
//  FaceView.swift
//  Faceit
//
//  Created by Vernsu on 16/8/23.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {

    //可供配置的属性
    //Swift可以推断出property类型，但是要用IBInspectable时，一需要显示的申明类型，不然interface builder不能推断出来
    @IBInspectable
    var scale:CGFloat =  0.9 { didSet{ setNeedsDisplay() } }
    @IBInspectable
    var mouthCurvature: Double = 1.0 { didSet{ setNeedsDisplay() } }// 1 full smile, -1 full frown
    @IBInspectable
    var eyesOpen:Bool = false { didSet{ setNeedsDisplay() } }
    @IBInspectable
    var eyeBrowTilt:Double = 1  { didSet{ setNeedsDisplay() } }// -1 full furrow, 1 full relaxed
    @IBInspectable
    var color:UIColor = UIColor.blueColor() { didSet{ setNeedsDisplay() } }
    @IBInspectable
    var lineWidth:CGFloat = 5.0 { didSet{ setNeedsDisplay() } }
    
    
    
    //因为没有初始化无法访问bounds，把它改成计算属性（computer property），注意，这里没有用get。如果你的计算属性只需要get，你就可以简单得这样写。
    private var skullRadius:CGFloat{
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var skullCenter:CGPoint{
        return CGPoint(x: bounds.midX , y: bounds.midY )
    }
    
    //swift中设置常量的方式，我们创建一个结构体（struct）,运用static关键字。使用let。注意名称首字母大写。
    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    }
    
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func pathForCircleCenteredAtPoint(midPoint:CGPoint, withRadius radius:CGFloat) -> UIBezierPath {
        //中心点，半径，起始角度，结束角度，是否顺时针.0.0是一个字面量，它会自动转化为合适的参数类型
        let path =  UIBezierPath(
            arcCenter: midPoint,
            radius: radius,
            startAngle: 0.0,
            endAngle:CGFloat( 2*M_PI),
            clockwise: false)
        
        path.lineWidth = lineWidth
        return path
    }
    
    private func getEyeCenter(eye:Eye) -> CGPoint {
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye {
        case .Left:
            eyeCenter.x -= eyeOffset
        case .Right:
            eyeCenter.x += eyeOffset
            
        }
        return eyeCenter
    }
    
    private func pathForEye(eye:Eye) -> UIBezierPath
    {
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye)
        if eyesOpen {
            return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
        }else{
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLineToPoint(CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
            return path
        }
        
        
    }
    
    //用贝赛尔曲线画嘴
    private func pathForMouth() -> UIBezierPath {
        //贝叶斯曲线是通过两个点画一个曲线，但是你还可以有两个控制点，
        //P0、P1、P2、P3四个点在平面或在三维空间中定义了三次方贝塞尔曲线。曲线起始于P0走向P1，并从P2的方向来到P3。一般不会经过P1或P2；这两个点只是在那里提供方向资讯。P0和P1之间的间距，决定了曲线在转而趋进P2之前，走向P1方向的“长度有多长”。
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        

        let mouthRect = CGRect(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
       
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
        
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2:cp2)
        path.lineWidth = lineWidth
        
        return path
        
    }
    //眉毛
    private func pathForBrow(eye: Eye) -> UIBezierPath
    {
        var tilt = eyeBrowTilt
        switch eye {
        case .Left: tilt *= -1.0
        case .Right: break
        }
        var browCenter = getEyeCenter(eye)
        browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1, min(tilt, 1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
        let path = UIBezierPath()
        path.moveToPoint(browStart)
        path.addLineToPoint(browEnd)
        path.lineWidth = lineWidth
        return path
    }
    
    override func drawRect(rect: CGRect) {
     
        color.set()
        
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(.Left).stroke()
        pathForBrow(.Right).stroke()
        
        
    }


}
