//
//  Tweet.swift
//  Smashtag
//
//  Created by Vernsu on 16/9/18.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Tweet: NSManagedObject {

//这个方法先查看database，如果这个tweet已经存在了（uniqueID），直接返回它；如果没有就得到的信息转化一个，返回它
    class func tweetWithTwitterInfo(twitterInfo: Twitter.Tweet, inManagedObjectContext context:NSManagedObjectContext) -> Tweet? {//这里用optional，可以实现由于一些原因我没能创建，我可以返回一个默认的nil
        
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        //如果有，返回。这些代码太多行，可以只写一行
        /*
        do{
            let queryResults = try context.executeFetchRequest(request)
            if let tweet = queryResults.first as? Tweet{
                return tweet
            }

        }catch let error{
            //ignore
        }
        */
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return tweet
        }
        else  if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet{
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created
            
            //TwitterUser里的tweets会自动有这条tweet，因为他们是relationship。所以relationship不需要两边都设置。
            tweet.tweeter = TwitterUser.twitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            
            return tweet
        }
        
    
        return nil
    }

}
