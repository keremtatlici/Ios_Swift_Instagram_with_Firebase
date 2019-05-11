//
//  Post.swift
//  Fetch
//
//  Created by shakabrah on 03/05/2019.
//  Copyright © 2019 Ktü. All rights reserved.
//

import Foundation
class Post {
    var caption : String
    var postUrl : String
    var usernm : String
    var likecount: Int
    
    init(captionText : String , photoUrlString: String, userNameText: String,likeCount: Int) {
        caption = captionText
        postUrl = photoUrlString
        usernm = userNameText
        likecount = likeCount
    }
}
