//
//  BottomBlock.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/24.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit

protocol InputChatDelegate {
    func sendChat(_ textchat: String)
}

class InputChat: UIView {

    var delegate: InputChatDelegate? = nil
    @IBOutlet weak var textChatField: UITextView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        initNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initNib()
    }
    
    func initNib() {
        
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 70, width: UIScreen.main.bounds.size.width, height: 70)
    }
    
    @IBAction func clickSendButton() {
    
        self.delegate?.sendChat(self.textChatField.text!)
        self.textChatField.text = ""
    }
    
    
}
