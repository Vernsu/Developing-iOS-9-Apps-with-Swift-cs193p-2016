//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Vernsu on 16/9/11.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController,UITextFieldDelegate {

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
            request.fetchTweets{ [weak weakSelf = self] newTewwts in
                dispatch_async(dispatch_get_main_queue(), {
                    //3
                    if request == weakSelf?.lastTwitterRequest{
                        if !newTewwts.isEmpty{
                            weakSelf?.tweets.insert(newTewwts, atIndex: 0)
                        }
                    }

                })
            }
        }
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
        static let TweetCellIdentifier = "Tweet"
    }

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
