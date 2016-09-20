//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Vernsu on 16/9/11.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import Twitter
import CoreData
class TweetTableViewController: UITableViewController,UITextFieldDelegate {

    //我们需要一个object context，让我们方便操作database.optionall类型，如果是nil，就不能update database。所以想要update database 就要设置这个。
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    //这里定义一个嵌套数组，因为有多个section。这样正好可以和section 和 row的数据对应起来
    var tweets = [Array<Twitter.Tweet>](){
        didSet{
            tableView.reloadData()
        }
    }
    
    
    var searchText:String?{
        didSet{
            tweets.removeAll()
            searchForTweets()
            title = searchText
            
        }
    }
    
    //这是一个计算属性
    private var twitterRequest: Twitter.Request?{
        //并且 string 不为空
        if let query = searchText where !query.isEmpty{
            return Twitter.Request(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    //为了确保是最新数据的变量1
    private var lastTwitterRequest: Twitter.Request?
    
    private func  searchForTweets(){
        if let request = twitterRequest{
            //2
            lastTwitterRequest = request;
            request.fetchTweets{ [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue(), {
                    //3
                    if request == weakSelf?.lastTwitterRequest{
                        if !newTweets.isEmpty{
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            //在请求返回时更新数据库
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }

                })
            }
        }
    }
    private func updateDatabase(newTweets:[Twitter.Tweet]){
        //记住，任何时候我们存取database，我们都在 perform block 中做，因为managedObjectContext，只有在它被创建的线程中，才是线程安全的。我把所有的代码都写在这个block中，假装我们不知道什么线程创建的managedObjectContext。即使我们知道，AppDelegate的managedObjectContext总是在 main queue里的。
        //如果managedObjectContext是nil，发生什么？ nothing 这是我们想要的
        managedObjectContext?.performBlock({
            
            //接下来我们要把newTweets保存到database中
            for twitterInfo in newTweets{
                
                //创建一个新的 unique的 Tweet ，从网络中拿到的数据转换，应该放到Tweet中
                //此时managedObjectContext不是nil，如果是nil就不会执行到这里
                //如果有返回值，但是这里不需要，就不用写 =
                //Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
                //但是为了代码的可读性，告诉后来者，这个方法有返回值，可以这样写。 _在swift是通用符，我不关心它是什么的时候用。
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
                
                //这个我们将这些tweets载入到了database，但是没有save它。如果我们用的managed document，它会autosaving。但是我们用的是 app delegate的。
                //但是有时候要考虑到使用api的人不一定使用哪种，所以两种情况都手动保存一下也没问题。
                do{
                    try self.managedObjectContext?.save()
                }catch let error{
                    print("Core Data Error: \(error)")
                }
            }
        })
        //打印保存的数据
        //为什么放在这里可以打印，不怕数据还没存完么？
        //不怕，因为print也在performBlock中，performBlock是异步的。block将他们放入对应的queue中，在这里是main queue；不关心queue究竟是那个，放进去而已。
        //所以我们看到的结果可能是这样的,先打印了『down』
        /*
         down printing database statistics
         74 TwitterUsers
         101 Tweets
         */
        printDatabaseStatistics()
        print("down printing database statistics")
    }
    //print 有多少user 和多少 tweet
    private func printDatabaseStatistics(){
        managedObjectContext?.performBlock({ 
            //这里不需要predicate，因为我要的是所有的，不需要筛选
            if let results = try?  self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")){
                print("\(results.count) TwitterUsers")
            }
            //但是有更好的办法
            //这样做会把每个TwitterUser从database中取出，并且放入内存中。这里仅仅是一些外壳（因为faulting），他们的attributes并没有从dadabase中取出来。但即时是只有上千个外壳，也是没必要放到内存中的。更好的办法是只得到count，而不需要把所有东西放到数组中。
            //tweet就会这样做
            //这个方法很有意思，没有throw error，而是返回了一个pointer
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName:"Tweet") , error: nil)
            print("\(tweetCount) Tweets")
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //此处将估算高度设置为storboard中cell原型的高度
        tableView.estimatedRowHeight = tableView.rowHeight
        //iOS8 系统中 rowHeight 的默认值已经设置成了 UITableViewAutomaticDimension，所以可以省略。
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchText = "#stanford"

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    private struct Storboard{
        static let TweetCellIdentifier = "Tweet"    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storboard.TweetCellIdentifier , forIndexPath: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        
        
        if let tweetCell = cell as? TweetTableViewCell{
            tweetCell.tweet = tweet
        }
        
        return cell
    }


    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.delegate = self
            searchTextField.text = searchText
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetersMentioningSearchTerm"{
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController{
                tweetersTVC.mention = searchText;
                tweetersTVC.managedobjectContext = managedObjectContext
            }
        }
    }


}
