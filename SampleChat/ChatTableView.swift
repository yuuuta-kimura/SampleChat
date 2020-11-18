//
//  ChatTableView.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/25.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit

class ChatTableView: UITableView {
    
    var inputview: InputChat?
    //var inputview: longpressChat?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputview?.endEditing(true)
    }
    
}
