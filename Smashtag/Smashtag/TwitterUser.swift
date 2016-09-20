//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Vernsu on 16/9/18.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class TwitterUser: NSManagedObject {

//这个方法和Tweet中的基本一样
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser?
    {
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            //这里没有设置user的tweets（NSSet）
            return twitterUser
        }
        return nil
    }
}
