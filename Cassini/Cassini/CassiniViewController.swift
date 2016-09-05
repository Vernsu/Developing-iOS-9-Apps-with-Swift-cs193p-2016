//
//  CassiniViewController.swift
//  Cassini
//
//  Created by Vernsu on 16/9/5.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController {
//一个清洁代码的技巧：将storyboard中的常量存储在一个私有struct中
    private struct Storyboard{
        static let ShowImageSegue = "Show Image"
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowImageSegue{
            if let ivc = segue.destinationViewController.contentViewController  as? ImageViewController {
                //如果sender as? UIButton为nil，整句就会被忽略。optional chaining，？意味着，如果(sender as? UIButton)是nil，那(sender as? UIButton)? .currentTitle就返回nil，并且忽略它
                 let imageName = (sender as? UIButton)? .currentTitle
                 ivc.imageURL = DemoURL.NASAImageNamed(imageName)
                ivc.title = imageName
         
           
            }
        }
        
    }


}

extension UIViewController{
    var contentViewController : UIViewController {
        if let navcon = self as? UINavigationController{
            return navcon.visibleViewController ?? self
        }else{
            return self
        }
    }
}

















