//
//  CassiniViewController.swift
//  Cassini
//
//  Created by Vernsu on 16/9/5.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate {
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
    
    @IBAction func showImage(sender: UIButton) {
        //这里借用iphone和ipad对splitVC的不同实现方式
        //这里如果取【1】的话可能会导致crash
        if let ivc = splitViewController?.viewControllers.last?.contentViewController as? ImageViewController{
            let imageName = sender.currentTitle
            ivc.imageURL = DemoURL.NASAImageNamed(imageName)
            ivc.title = imageName
            
        }else{
            //iphone时，用代码调用segue
            performSegueWithIdentifier(Storyboard.ShowImageSegue, sender: sender)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }


    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self{
            if let ivc = secondaryViewController.contentViewController as? ImageViewController where ivc.imageURL == nil {
                return true
            }
        }
        return false
        
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

















