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
            //这里是一个网络请求，需要占用内存。所以只有当view出现在屏幕上时我们才去请求。这是一个可靠的判断view是否出现在屏幕上的方法
            if view.window != nil{
                 fetchImage()
            }
           
        }
    } 
    
    private func fetchImage(){
        if let url = imageURL {
            //多线程
            //使用了weakSelf后，离开这个MVC，controller会被释放，如果clasure还在抓取中，clasure就还在heap，但是一旦抓去成功，内存就会被释放。
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                let contentOfURL = NSData(contentsOfURL: url)
                
                dispatch_async(dispatch_get_main_queue(), {  [ weak weakSelf = self] in
                    //在多线程中，我们要确保我们得到的数据是我们当前最新请求的数据，有可能我们短时间会发出多次不同参数的请求，我们只要最后一次的数据显示出来
                    if url == weakSelf?.imageURL{
                        if let imageData =  contentOfURL{
                            self.image = UIImage(data: imageData)
                        }else{
                            weakSelf?.spinner?.stopAnimating()
                        }
                    }else{
                        print("ignored data returned from url \(url)")
                    }
                
                })
               
            })
           
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
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //此时应判断数据是否已经存在，若存在，不应该重复请求
        if image == nil{
            fetchImage()
        }
    }
 

}











