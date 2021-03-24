//
//  InputViewController.swift
//  taskapp
//
//  Created by 松本光輝 on 2021/03/16.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")
        }
        // 未通知のローカル通知一覧をログ
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
        //背景タップでdismissKeyboardを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        //タイトルと内容を設定
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
    }
    // ローカル通知が発動するtrigger（日付マッチ）
    let calendar = Calendar.current
    lazy var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    lazy var trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    // ローカル通知を作成
    let content = UNMutableNotificationContent()
    lazy var request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
    
    // ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
}
