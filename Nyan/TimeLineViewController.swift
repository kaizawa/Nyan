//
//  TimeLineViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/06/25.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import Social
import Accounts

class TimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    let config:Config = Config.sharedInstance
    let accountManager = AccountManager.sharedInstance
    var refreshControl:UIRefreshControl!
    var timeline: [AnyObject] = [AnyObject]()
    let semaphore = DispatchSemaphore(value: 1)

    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // 時間がかかる処理なのでサブスレッド(global queue)で呼ばれるべき
    func updateTimeline()
    {
        
        let homeTimelineUrl = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let params = ["count": "50"]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET,
            url: homeTimelineUrl as URL!,
            parameters: params)
        
        request?.account = accountManager.getAccount(name: config.account!)

        self.semaphore.wait()
        request?.perform {(responseData, response, error) -> Void in

            if error != nil {
                print(error as Any)
            } else {
                do {
                    self.timeline.removeAll()
                    let result = try JSONSerialization.jsonObject(
                        with: responseData!, options: .allowFragments)
                    for tweet in result as! [AnyObject] {
                        self.timeline.append(tweet)
                    }
                }  catch let error as NSError {
                    print(error)
                }
            }
            DispatchQueue.main.async {
                // UI更新はメインスレッド で実行
                self.tableView.reloadData()
                self.semaphore.signal()
            }
        }
        self.semaphore.wait()
        self.semaphore.signal()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "読み込み")
        self.refreshControl.addTarget(self, action: #selector(TimeLineViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)

        self.refreshControl.beginRefreshing()
        refresh()
    }
    

    /*
     * UIRefreshControl によって画面を縦にフリックしたあとに(=リフレッシュ)呼ばれる
     */
    func refresh()
    {
        DispatchQueue.global().async {

            self.updateTimeline()
        }
        self.semaphore.wait()
        self.semaphore.signal()
        refreshControl.endRefreshing()
    }
    
    /*
     * テーブルの行数を返す
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return timeline.count
    }

    
    /*
     * 指定行のセルデータを返す
     */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as? TweetCell else {
            return UITableViewCell()
        }
        
        
        // ステータス
        cell.status?.text = timeline[row]["text"] as? String

        // ユーザ
        let user = timeline[row]["user"] as? [String: Any]
        cell.tweet = timeline[row] as? [String:Any]
        
        cell.name?.text = user?["name"] as? String

        // アイコンのURLをとってきてプロトコルをHTTPに変更
        let urlString = (user?["profile_image_url_https"] as! String)

        // キャッシュしているアイコンを取得
        if let cacheImage = self.config.iconCache.object(forKey: urlString as AnyObject) {
            // キャッシュ画像の設定
            cell.icon.image = cacheImage
            return cell
        }
        
        // アイコンはキャッシュに存在しない
        guard let url = URL(string: urlString) else {
            // urlが生成できなかった
            return cell
        }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) {
            (data:Data?, response:URLResponse?, error:Error?) in

            guard error == nil else {

                return
            }
            
            guard let data = data else {

                return
            }
            
            guard let image = UIImage(data: data) else {

                return
            }
            
            // ダウンロードしたアイコンをキャッシュする
            self.config.iconCache.setObject(image, forKey: urlString as AnyObject)
            
            // メインスレッドで表示
            DispatchQueue.main.async {
                cell.icon.image = image
            }
        }
        // 画像の読み込み処理開始
        task.resume()
        
        return cell
    }
    
    /*
     * 行をタップされたときに呼ばれる。(いまはOuputに文字列をプリントしてるだけ)
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath)
    {
        print(timeline[indexPath.row]["text"] as? String ?? "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? TweetCell {

            if let tweetViewController = segue.destination as? TweetViewController {
                tweetViewController.tweet = cell.tweet
            }
        }
    }
}
