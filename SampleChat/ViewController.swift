//
//  ViewController.swift
//  SampleChat
//
//  Created by 木村 優太 on 2019/07/24.
//  Copyright © 2019 木村 優太. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InputChatDelegate, UIGestureRecognizerDelegate, longpressChatDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    private var bottomView = InputChat()
    private var longpressView = longpressChat()
    private var longpressCell: UIView! = nil
    private var chats: [ChatSpeak] = []
    private var db:Firestore!
    private var listener: ListenerRegistration!
    private var sendflg: Bool = false
    private var longpressIndex = 0
    
    private let chatroomid = "HJg6EKs2jdcuRjlwhoWE"
    private let speakerid = "09olxvcsK44UC0DoICkn"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.db = Firestore.firestore()
        
        updateInitDocument()
        listenDocument() //チャットの変更をリッスン
        SetTableViewUI() //テーブルビューのセット
        SetInputTextUI() //テキスト入力フォームのセット
        self.sendflg = false
        
    }

    ////////////////////////////////
    // 送信ボタンクリック
    func sendChat(_ textchat: String) {
        self.view.endEditing(true) //キーボード閉じる

        if textchat != "" {
            //Firebaseにテキスト内容を格納
            self.sendflg = true
            var ref: DocumentReference? = nil
            ref = db.collection("friends-chatrooms").document(chatroomid).collection("chat").addDocument(data: [
                "talk": textchat,
                "speaker": speakerid,
                "create-time": Timestamp(date: Date())
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    ////////////////////////////////
    // セルを長押しで削除選択表示
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        // 押された位置でcellのPathを取得
        let point = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        
        if indexPath == nil {
            
        } else if sender.state == UIGestureRecognizer.State.began  {
            if longpressCell == nil {
                if chats[indexPath!.section].usertype == .me
                {
                    self.longpressIndex = indexPath!.section //長押しセルに変更を加えるために位置を記憶
                    SetupLongpressUI() //入力用ビューから長押し用ビューに変更
                    longpressCell = sender.view
                    longpressCell.backgroundColor = UIColor.green
                }
            }
        }
    }

    ////////////////////////////////
    // セル長押しビューのキャンセルボタン
    func longpressCancel() {
        self.view.addSubview(bottomView)
        longpressCell.backgroundColor = UIColor.white
        longpressCell = nil
    }

    ////////////////////////////////
    // セル長押しビューのチャット削除ボタン
    func longpressDelete() {
        let docid = chats[longpressIndex].docid
        chats.remove(at: longpressIndex)
        self.tableView.reloadData()
        longpressCell = nil
        self.view.addSubview(bottomView)
    self.db.collection("friends-chatrooms").document(chatroomid).collection("chat").document(docid).delete()
    }
    
    ////////////////////////////////
    // Firestoreの変更をチャットに反映
    func listenDocument() {
        
        //Firestoreからデータを取得し、TextViewに表示する
        self.listener = self.db.collection("friends-chatrooms").document(chatroomid).collection("chat").addSnapshotListener { (snapShot, error) in
            guard let value = snapShot else {
                print("snapShot is nil")
                return
            }
            
            if self.sendflg {
                value.documentChanges.forEach{diff in
                    //更新内容が追加だったときの処理
                    if diff.type == .added {
                        self.DocumentToChats(diff.document, last:true)
                        self.tableView.reloadData() //リロードするとイベントが発火してチャットデータをロード
                        self.sendflg = false
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.chats.count - 1), at: UITableView.ScrollPosition.bottom, animated: false) //一番下にスクロール
                    }
                }
            }
        }
    }
    
    ////////////////////////////////
    // Firestoreの初期表示用データを取得
    func updateInitDocument() {
        reloadDefaultChatData(chatroomid, 5)
    }

    ////////////////////////////////
    // バウンスで過去分チャット表示
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0 {
            reloadPastChatData(chatroomid, 5, self.chats.first!.time)
        }
    }

    ////////////////////////////////
    // 初期のチャット表示
    private func reloadDefaultChatData(_ documentID: String, _ row: Int) {
        let ref = db.collection("friends-chatrooms").document(documentID).collection("chat")
        ref
            .order(by: "create-time", descending: true)
            .limit(to: row)
            .getDocuments() {(snapshot, err) in
            for document in snapshot!.documents {
                self.DocumentToChats(document, last:false)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.chats.count - 1), at: UITableView.ScrollPosition.bottom, animated: false) //一番下にスクロール
            }
        }
    }

    ////////////////////////////////
    // 過去のチャット表示
    private func reloadPastChatData(_ documentID: String, _ row: Int, _ fromtime: Date) {
        let ref = db.collection("friends-chatrooms").document(documentID).collection("chat")
        ref
            .order(by: "create-time", descending: true)
            .limit(to: row)
            .whereField("create-time", isLessThan: fromtime)
            .getDocuments() {(snapshot, err) in
            for document in snapshot!.documents {
                self.DocumentToChats(document, last: false)
                self.tableView.reloadData()
            }
        }
    }
    
    ////////////////////////////////
    // FireStoreからチャット表示用配列をコピー
    func DocumentToChats(_ document: DocumentSnapshot, last blast: Bool) {
        let talk = document.get("talk") as! String
        let createtime = document.get("create-time") as! Timestamp
        let speaker = document.get("speaker") as! String
        let docid = document.documentID
        var usertype: UserType
        if speaker == speakerid {
            usertype = .me
        } else {
            usertype = .you
        }
        let chat = ChatSpeak(docid: docid, text: talk, time: createtime.dateValue(), usertype: usertype)
        if blast {
            self.chats.append(chat) //最後にチャットデータを追加
        } else {
            self.chats.insert(chat, at: 0) //先頭にチャットデータを追加
        }
    }
    
    ////////////////////////////////
    // チャット表示用のテーブルビュー設定
    func SetTableViewUI() {

        //テーブルビューの設定
        tableView.register(UINib(nibName: "MyTableCell", bundle: nil), forCellReuseIdentifier: "MyTableCell")
        
        
        tableView.register(UINib(nibName: "YourTableCell", bundle: nil), forCellReuseIdentifier: "YourTableCell")
        
        self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        tableView.separatorColor = UIColor.clear // セルを区切る線を見えなくする
        tableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        tableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        tableView.allowsSelection = false // 選択を不可にする
        tableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる

    }

    ////////////////////////////////
    // チャット入力用のビュー設定
    func SetInputTextUI() {
        
        self.bottomView = Bundle.main.loadNibNamed("InputChat", owner: self, options: nil)!.first! as! InputChat

        self.view.addSubview(bottomView)
        (tableView as! ChatTableView).inputview = bottomView
        bottomView.delegate = self

    }

    ////////////////////////////////
    // セル長押し用のビュー設定
    func SetupLongpressUI() {
        self.longpressView = Bundle.main.loadNibNamed("longpressChat", owner: self, options: nil)!.first! as! longpressChat
        self.view.addSubview(longpressView)
        self.longpressView.delegate = self
        
    }
    
    ////////////////////////////////
    // チャット動作設定
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30 //テーブルセルの間に隙間を作る
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear //隙間を透明にする
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //セクションごとにスペースを作っているので、Rowは１つ
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.chats.count
    }
    
    ////////////////////////////////
    // テーブルセルのカスタムビューを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = self.chats[indexPath.section]
        
        var cell:UITableViewCell
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(ViewController.longPress(_:)))
        gesture.delegate = self
        
        switch chat.usertype {
        case .me:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "MyTableCell") as! MyTableCell
            let mycell: MyTableCell = cell as! MyTableCell
            mycell.updateCell(chat)
            mycell.autosizeView.addGestureRecognizer(gesture) //ラベルを覆っているViewに長押しジェスチャーのリッスンを登録
            
        case .you:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "YourTableCell") as! YourTableCell
            
            let yourcell = cell as! YourTableCell
            yourcell.updateCell(chat)
            yourcell.autosizeView.addGestureRecognizer(gesture) //ラベルを覆っているViewに長押しジェスチャーのリッスンを登録
            
        }
        
        return cell
    }

    
    ////////////////////////////////
    // キーボード自動上下設定
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Viewの表示時にキーボード表示・非表示を監視するObserverを登録する
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Viewの終了時にキーボード表示・非表示時を監視していたObserverを解放する
        let notification = NotificationCenter.default
        notification.removeObserver(self)
        notification.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.listener.remove()
        
    }
    
    ////////////////////////////////
    //キーボード表示時の動作
    @objc func keyboardWillShow(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let duration:TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        //インプットフィールドのカスタムセルを移動
        let keyboardRect:CGRect = keyboardInfo.cgRectValue
        UIView.animate(withDuration: duration, animations: {
            self.bottomView.frame.origin.y = keyboardRect.origin.y - self.bottomView.frame.size.height
        },completion:{(finished:Bool) in
            self.bottomView.frame.origin.y = keyboardRect.origin.y - self.bottomView.frame.size.height
        })
    }
    
    ////////////////////////////////
    //キーボード非表示時の動作
    @objc func keyboardWillHide(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let duration:TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        let keyboardRect:CGRect = keyboardInfo.cgRectValue
        UIView.animate(withDuration: duration, animations: {
            self.bottomView.frame.origin.y = keyboardRect.origin.y - self.bottomView.frame.size.height
        },completion:{(finished:Bool) in
            self.bottomView.frame.origin.y = UIScreen.main.bounds.size.height - self.bottomView.frame.size.height
        })
    }
    
    ////////////////////////////////
    //キーボード非表示時の動作
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

