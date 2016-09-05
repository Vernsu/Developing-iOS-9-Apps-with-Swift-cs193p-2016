//
//  ImageViewController.swift
//  Cassini
//
//  Created by Vernsu on 16/9/4.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController , UIScrollViewDelegate{

    //注意，这是存储属性
    var imageURL:NSURL?{
        didSet{
            image = nil
            fetchImage()
        }
    } 
    
    private func fetchImage(){
        if let url = imageURL {
            if let imageData = NSData(contentsOfURL: url){
                image = UIImage(data: imageData)
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize  = imageView.frame.size
            scrollView.delegate = self
            scrollView.maximumZoomScale = 1.0
            scrollView.minimumZoomScale = 0.03
        }
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    
    //计算属性，注意没有设置image的值，他实际上将数据存储在别的地方。
    private var image:UIImage?{
        get{
            return imageView.image
        }
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            //这里为什么要用？因为scrollView是letout，当我们在preparing时设置了image，此时scrollView还不存在.所以我们在两个地方设置了contentSize
            scrollView?.contentSize  = imageView.frame.size
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        // Do any additional setup after loading the view.
    }


}
