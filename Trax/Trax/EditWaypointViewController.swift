//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Vernsu on 16/10/26.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController ,UITextFieldDelegate{

    var waypointToEdit:EditableWaypoint? { didSet{updateUI()}}
    private func updateUI(){
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text  = waypointToEdit?.info
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //使用autolayout计算viewsize
        //用AutoLayout告诉我最合适的size,ExpandedSize意思是尽可能大的。CompressedSize尽可能小的
        preferredContentSize = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    private func stopListeningToTextFields(){
        if let observer = ntfObserver{
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let obserber = itfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(obserber)
        }
        
    }
    private func listenToTextFields(){
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(
            UITextFieldTextDidChangeNotification,
            object: nameTextField,
            queue: queue)
        { (notification) in
            if let waypoint = self.waypointToEdit{
                waypoint.name = self.nameTextField.text
            }
                
        }
        itfObserver = center.addObserverForName(
            UITextFieldTextDidChangeNotification,
            object: infoTextField,
            queue: queue)
        { (notification) in
            if let waypoint = self.waypointToEdit{
                waypoint.info = self.infoTextField.text
            }
            
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {didSet{nameTextField.delegate = self}}
    @IBOutlet weak var infoTextField: UITextField! {didSet{infoTextField.delegate = self}}
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
