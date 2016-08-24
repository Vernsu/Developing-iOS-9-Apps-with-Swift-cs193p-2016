//
//  ViewController.swift
//  Calculator
//
//  Created by Vernsu on 16/8/1.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {


    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    

    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping{//我们不实用显示是否为『0』去判断输入状态，而是使用一个状态可判断。因为「0」可以会在输入中出现
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }else{
            display.text = digit;
        }
        userIsInTheMiddleOfTyping = true
    }
    
    
    
    private var displayValue:Double{//这样的作用是我们只需要计算值，计算器显示的结果就会自动呈现
        get{
            //字符串转double时，生成的是Double？  因为字符串不总是能转化成Double
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)//newValue就是设置的新值
        }
    }
    
    var savedProgram:CalculatorBrain.PropertyList?
    @IBAction func save(sender: AnyObject) {
        savedProgram = brain.program
        
    }
    
    @IBAction func restore(sender: AnyObject) {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let  mathematicalSymbol = sender.currentTitle{
            
            brain.performOperation(mathematicalSymbol)
            
        }
        displayValue = brain.result
        
    }
}

