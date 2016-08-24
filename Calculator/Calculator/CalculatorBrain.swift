//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vernsu on 16/8/6.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    private var accumulator = 0.0
    
    // AnyObject 的数组来存储信息，数组中的元素可能是 Double 类型，可能是一个 String 类型。我只需将操作数以 Double 的形式进行存储，将操作符以 String 的形式进行存储。这里使用的是 AnyObject 类型做为数组元素的类型,但是一个 Double 的类型， 它是一个Struct。 原本应该是没办法存入数组中的， 但是苹果的桥接技术做到了， 就是与 Objective-C 的桥接技术
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand:Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    //值的类型为Operation
    var operations:Dictionary<String,Operation > = [
        //枚举关联值后，传入值即可
        "π":Operation.Constant(M_PI),// M_PI,
        "e":Operation.Constant(M_E),//M_E
        "±":Operation.UnaryOperation({-$0}),
        "√":Operation.UnaryOperation(sqrt),//这里只要写函数名即可
        "cos":Operation.UnaryOperation(cos),// cos
        "×":Operation.BinaryOperation({$0*$1}),
        "+":Operation.BinaryOperation({$0+$1}),
        "−":Operation.BinaryOperation({$0-$1}),
        "÷":Operation.BinaryOperation({$0/$1}),
        "=":Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)//我们可以把Double和constant关联起来，即给Constant关联了一个值（Double类型）
        case UnaryOperation((Double) -> Double)//如何让一个函数成为关联值？在swift中函数类型和double类型没什么区别.这个函数有double类型的参数和double类型的返回值。这就是一元计算的关联值
        case BinaryOperation((Double,Double) -> Double)//二元运算，比如3*5，在我按下乘号的时候我没有足够的信息，只有按下等号键才开始运算
        case Equals
    }
    
    func performOperation(symbol:String)  {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            //怎么把关联的值取出来？定义一个局部变量，名字可以随便取.这个局部变量会和关联值连接起来
            //这样就可以处理一些模式匹配的工作了
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
                //这里的关联值是一个函数
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()//按下乘号时，自动处理等号事件
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)//计算5*3，当我按下乘号，我所做的就是建立了这样一个结构体
            case .Equals:

                executePendingBinaryOperation()
            
            }
            
        }
        
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending  = nil
        }
    }
    
    private var pending:pendingBinaryOperationInfo?//pending只在执行二元运算时才有值，所以用可选型。如果我没有输入*等时，我希望他是nil
    //结构体
    //结构图非常像类，几乎是一样的，可以有变量，存储变量，计算变量，但是没有继承。结构体和类最大的区别是，结构体和枚举一样是按值传递的，类是按引用传递的。
    //按引用传递就是它存储在堆里，内存中的某个地方，当你把它传递给某个方法，或者其他什么，你实际上传递的是它的指针。当你把它传递给A，A就有了一个同一个它，因为你们拥有的是同一个指针，都指向堆里存储的这个东西。
    //按值传递的意思就是，当你传递时，它会进行拷贝   
    //数组，是一个结构体，Double是一个结构体，int也是一个结构体，String也是结构体。如果我们把数组传递给一个方法，接着我在数组上添加些什么，它不会添加到原先的数组里。因为方法得到的是一个拷贝。那传递一个1000000长度的数组岂不是很慢，传递的时候，要拷贝所有元素。实际上，当你按值传递的时候swift相聪明，他不会真的进行拷贝，直到你试图使用它时。如果你试图更改，那么它会进行必要的拷贝，甚至不会拷贝全部元素，接着它会被改变，所以如果你传递了某些元素但有不使用，那么他不会被拷贝
    struct pendingBinaryOperationInfo  {
        var  binaryFunction:(Double,Double) -> Double  //二元操作方法，申明它，和一个普通的对象没什么区别
        var firstOperand:Double //我们需要记下第一个操作数。我没有初始化，但也没有任何警告。因为类有一个默认初始化方法，比如本类CalculatorBtain()。在结构体中，默认初始化方法的参数就是这个结构体里所有的变量。
    }
    //我们只在model内部set该属性，所以不要实现set方法，可以保护API，这样就变成了一个只读属性
    
    //这里虽然我给他的类型为 AnyObject， 但是我同时也可以给他的类型为 PropertyList， 因为这个名字更加有可读性。其他人可以将其存在 NSUserDefaults 或者是其他的地方。这里就要用到一个 Swift 的一个特性， 叫做 typealias 。typealias 让你可以创建一个新的类型， 一个别名的类型，它实际上与你绑定的类型是等价的。这里创建一个叫做 PropertyList 的类型，并且它与AnyObject 等价。为什么我要创建这个类型呢？因为我希望这里的类型名称是 PropertyList,这本质上是一种文档化
    typealias  PropertyList = AnyObject
    
    var program:PropertyList{
        //
        get{
            return internalProgram
        }
        set{
            clear()
            //这里是重新计算，所以我们对操作数和操作符进行一遍计算
            //判断是否为anyobject数组
            if let arrayOfOps = newValue as? [AnyObject]{
                //遍历，检查每个元素
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    }else if let operation = op as? String{
                        performOperation(operation)
                    }
                }
                
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()//移除数组中所有元素
    }
    
    var result:Double{
        get{
            return accumulator
        }
    }
    
}