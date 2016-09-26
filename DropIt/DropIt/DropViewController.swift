//
//  DropViewController.swift
//  DropIt
//
//  Created by Vernsu on 16/9/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class DropViewController: UIViewController {


    @IBOutlet weak var gameView: DropItView!{
        didSet{
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addDrop(_:))))
        }
    }
    func addDrop(recognizer:UITapGestureRecognizer){
        if recognizer.state == .Ended {
            gameView.addDrop()
        }
    }

}
