//
//  longpressChat.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/08/02.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit

protocol longpressChatDelegate {
    func longpressCancel()
    func longpressDelete()
}

class longpressChat: UIView {

    var delegate: longpressChatDelegate? = nil
    
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
        
    @IBAction func clickCancel(_ sender: Any) {
        self.delegate?.longpressCancel()
    }

    @IBAction func clickDelete(_ sender: Any) {
        self.delegate?.longpressDelete()
    }
    
}
