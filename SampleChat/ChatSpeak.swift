//
//  ChatSpeak.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/22.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import Foundation
import UIKit

public class ChatSpeak {
    var text: String
    var time: Date
    var docid: String
    var usertype: UserType
    
    public init(docid: String, text: String, time: Date, usertype: UserType) {
        self.docid = docid
        self.text = text
        self.usertype = usertype
        self.time = time
    }

    
    public func isSpeaker() -> Bool {
        return usertype == .me
    }
}

public enum UserType {
    case me
    case you
}
