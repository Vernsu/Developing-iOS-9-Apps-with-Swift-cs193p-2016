//
//  AllQandAsTableViewController.swift
//  Pollster
//
//  Created by Vernsu on 16/10/20.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import CloudKit
class AllQandAsTableViewController: UITableViewController {
    var allQandAs = [CKRecord](){ didSet{ tableView.reloadData() } }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllQandAs()
        iCloudSubscribeToQandAs()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        iCloudUnsubscribeToQandAs()
    }
    
    
    private let database = CKContainer.defaultContainer().publicCloudDatabase
    private func fetchAllQandAs(){
        // 这是一个特殊的predicate，意思是所有。在coredata中 predicate为nil意味着所有。
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: Cloud.Entity.QandA, predicate: predicate)
        //排序
        query.sortDescriptors = [NSSortDescriptor(key: Cloud.Attribute.Question, ascending: true)]
        //zone就像database里的分区，通过分区 你可以让查询更有效率。因为如果你只需要查找你database中的一小部分，当然会查找的更快。这里我们没有用到nil
        database.performQuery(query, inZoneWithID: nil) { (records, error) in
            if records != nil{
                //注意闭包中不是在主线程，而更新UI应该在主线程
                dispatch_async(dispatch_get_main_queue(), { 
                    self.allQandAs = records!
                })
                
            }
        }
    }
    //MARK: Subscription
    
    private let subscroptionID  = "All QandA Creations and Deletions"
    private var cloudKitObserver:NSObjectProtocol?
    private func iCloudSubscribeToQandAs(){
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKSubscription(
            recordType: Cloud.Entity.QandA,
            predicate: predicate,
            subscriptionID: self.subscroptionID,
            options: [.FiresOnRecordCreation,.FiresOnRecordDeletion]
        )
        database.saveSubscription(subscription) { (savesSubscription, error) in
            if error?.code == CKErrorCode.ServerRejectedRequest.rawValue{
                //ignore
            }else if error != nil{
                //report
            }
        }
        cloudKitObserver  = NSNotificationCenter.defaultCenter().addObserverForName(
            CloudKitNotifications.NotificationReceived,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { notification in
                if let ckqn = notification.userInfo?[CloudKitNotifications.NotificationKey] as? CKQueryNotification{
                    self.iCloudHandleSubscriptionNotification(ckqn)
                }
            }
        )
    }
    private func iCloudHandleSubscriptionNotification(ckqn:CKQueryNotification){
        if ckqn.subscriptionID == self.subscroptionID {
            if let recordID = ckqn.recordID{
                switch ckqn.queryNotificationReason{
                case .RecordCreated:
                    database.fetchRecordWithID(recordID, completionHandler: { (record, error) in
                        if record != nil{
                            dispatch_async(dispatch_get_main_queue(), { 
                                self.allQandAs = (self.allQandAs + [record!]).sort{
                                    return $0.question < $1.question
                                }
                            })
                        }
                    })
                    
                    
                case .RecordDeleted:
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.allQandAs = self.allQandAs.filter{ $0.recordID != recordID }
                    })
                    
                default:
                    break
                }
            }
        }
    }
    private func iCloudUnsubscribeToQandAs(){
        database.deleteSubscriptionWithID(self.subscroptionID) { (subscroption, error) in
            
        }
        
    }
    
    //MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allQandAs.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QandA Cell" , forIndexPath: indexPath)
        cell.textLabel?.text  = allQandAs[indexPath.row][Cloud.Attribute.Question] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return allQandAs[indexPath.row].wasCreatedByThisUser
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let record  = allQandAs[indexPath.row]
            database.deleteRecordWithID(record.recordID, completionHandler: { (deleteRecord,   error) in
                //
            })
            allQandAs.removeAtIndex(indexPath.row)
        }
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show QandA" {
            if let ckQandATVC = segue.destinationViewController as? CloudQandATableViewController{
                //注意这个if判断的写法，可以写成一行
                if let cell = sender as? UITableViewCell , let indexPath = tableView.indexPathForCell(cell) {
                    ckQandATVC.ckQandARecord = allQandAs[indexPath.row]
                }else{
                    ckQandATVC.ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
 }
