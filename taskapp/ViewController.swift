//
//  ViewController.swift
//  taskapp
//
//  Created by 松本光輝 on 2021/03/16.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate{
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //カテゴリーの検索結果を表示
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            taskArray = taskArray.filter("category == '\(searchBar.text ?? "")'")
            tableView.reloadData()
    
    }
    
    //Realmのインスタンス
    let realm = try! Realm()
    //DBのうちのタスクが格納されるリスト
    //日付の近い順でソート:昇順
    //以降内容をアップデートするとリスト内は自動的に更新
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
        
    }
    
    //segueで画面遷移時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    let inputViewController:InputViewController = segue.destination as! InputViewController
    
        if segue.identifier == "cellSegue" {
                    let indexPath = self.tableView.indexPathForSelectedRow
                    inputViewController.task = taskArray[indexPath!.row]
                }else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
}
    
    //データの数(=セルの数)を返すメゾット
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なCellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定
        let task = taskArray [indexPath.row]
        cell.textLabel?.text = "[\(task.category ?? "")]\(task.title)" //変数名と文字列を結合　nillだったら""
    
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択時に実行するメゾット
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメゾット
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.delete
    }
    
    //Delete ボタン押下時の処理するメゾット
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //データベースから削除する
            try! realm.write {
            self.realm.delete(self.taskArray[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
//入力画面から戻ってきたら tableViewを更新
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
