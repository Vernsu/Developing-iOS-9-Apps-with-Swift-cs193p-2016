//
//  CloudQandATableViewController.swift
//  Pollster
//
//  Created by Vernsu on 16/10/18.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import CloudKit
class CloudQandATableViewController: QandATableViewController {

    var ckQandARecord: CKRecord{
        get{
            if _ckQandARecord == nil {
                _ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)//会调用_ckQandARecord的didSet
            }
            return _ckQandARecord!
        }
        set{
            _ckQandARecord = newValue
        }

    }
    
    //为什要这样写？因为需要初始化，但是又不想让外部的使用者设置为nil。
    private var _ckQandARecord: CKRecord?{
        didSet{
            let question = ckQandARecord[Cloud.Attribute.Question] as? String ?? ""
            let answers = ckQandARecord[Cloud.Attribute.Answers] as? [String] ?? []
            
            qanda = QandA(question: question, answers: answers)
            
            asking = ckQandARecord.wasCreatedByThisUser
        }
    }
    private let database = CKContainer.defaultContainer().publicCloudDatabase
    @objc private func iCloudUpdate(){
        if !qanda.question.isEmpty && !qanda.answers.isEmpty{
            ckQandARecord[Cloud.Attribute.Question] = qanda.question
            ckQandARecord[Cloud.Attribute.Answers] = qanda.answers
            iCloudSaveRecord(ckQandARecord)
        }

    }
    private func iCloudSaveRecord(recordToSave:CKRecord){
        database.saveRecord(recordToSave) { (savedRecord, error) in
            //这个错误意味着这条记录已经有别人保存了最新数据，你得到的是旧数据，而去覆盖别人写的新数据。甚至有可能是你自己，你保存了三四条数据，他们在队列中，其中的一个比别的更快的保存了。在这里我们假定新的是你想要的。
            if error?.code == CKErrorCode.ServerRecordChanged.rawValue{
                //ignore
            }else if error != nil{
                self.retryAfterError(error,withSelector:#selector(self.iCloudUpdate))
            }
        }
    }
    private func retryAfterError(error:NSError?,withSelector selector:Selector){
        //注意这个方法是在闭包中调用的，所以不再主线程。我们不能在其他线程中使用NSTimer
        if let retryInterval = error?.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval{
            dispatch_async(dispatch_get_main_queue(), { 
                NSTimer.scheduledTimerWithTimeInterval(
                    retryInterval,
                    target: self,
                    selector: selector,
                    userInfo: nil,   
                    repeats: false)
            })

        }
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        super.textViewDidEndEditing(textView)
        iCloudUpdate()
    }
 

}
