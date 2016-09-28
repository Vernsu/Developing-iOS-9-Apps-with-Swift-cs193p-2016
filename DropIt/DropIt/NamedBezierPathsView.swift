//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Vernsu on 16/9/28.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {

    
    var bezierPaths = [String : UIBezierPath]() { didSet { setNeedsDisplay() } }

        
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths{
            path.stroke()
        }
    }


}
