//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Vernsu on 16/9/17.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import CoreData
class TweetersTableViewController: CoreDataTableViewController {
    
    var mention: String? { didSet{ updateUI() } }
    //这里用optional挺好的 如果为nil 正好不显示数据
    var managedobjectContext: NSManagedObjectContext?{ didSet{ updateUI() } }


    private func updateUI(){
        //sectionNameKeyPath的含义是如果你有一个attribute在entities中，在tableview中你可能会用来做section。每个setcion会以相同的方式排序，排序是根据request的descriptors。设置为nil即不需要section。
        //如果 mention为nil 则mention?.characters.count 是nil 并被忽略， >知道nil不大于0，nil也不小于0，或者等于零
        if let context = managedobjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "TwitterUser")
            
            //并且不包含CarMo开头的名字
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "CatMo")//如果没有检测 这里使用mention! 可能会导致crssh，因为mention是个公开api，可能会没有设置，这是个糟糕的API设计
            
            
            //如果没有selector参数，这个排序会让A-Z排在a-z之前。
            request.sortDescriptors = [NSSortDescriptor(
                key: "screenName",//这个参数是attribute
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )
            ]
            //如果我们想让数据按照在指定话题下包含tweet的数量排序，我们要用另一种机制。我们要在可视化的data model中做这件事情。请参照阅读材料5
            
            
            
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }else{
            fetchedResultsController = nil
        }

    }
    private struct Storboard{
        static let TwitterUserCellIdentfier = "TwitterUserCell"
    }
    //这个方法返回一个optional
    private func tweetCountWithMentionByTwitterUser(user:TwitterUser) -> Int?{
        var count:Int?
        
        user.managedObjectContext?.performBlockAndWait({ 
            let request = NSFetchRequest(entityName: "Tweet")
            
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!,user)
            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)
            
        })
        
        
        
        
        
        
        
        return count
    }

     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier(Storboard.TwitterUserCellIdentfier, forIndexPath: indexPath)
        
        if let twitterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? TwitterUser{
            
            var screenName:String?
            
            //这里是存取database操作，任何时候存取数据库都应该放到performBlock中
            //任何NSmanagedobject都知道自己的managedObjectContext
            //这里要用performBlockAndWait ，因为 要等拿到name后 才能给cell
            twitterUser.managedObjectContext?.performBlockAndWait({
                //UI元素只能放在main queue中，这里，我们知道是 main queue。但是如果我在多线程中，就不能这样处理
                //cell.textLabel?.text = twitterUser.screenName
                screenName = twitterUser.screenName
                
            //由于我们要计算该user在当前话题下的tweet的数量，所以不能简单的用这个
            // count = twitterUser.tweets?.count

            })
            cell.textLabel?.text  = screenName
         
            //这个twitter有多少tweets
            
            if let count = tweetCountWithMentionByTwitterUser(twitterUser){
                cell.detailTextLabel?.text = (count == 1) ? "1 count" :"\(count) tweets"
            }else{
                cell.detailTextLabel?.text = ""
            }
        }

        
     // Configure the cell...
     
     return cell
     }


}
