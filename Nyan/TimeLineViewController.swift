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
import TwitterKit

class TimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    let config:Config = Config.sharedInstance
    var refreshControl:UIRefreshControl!
    var timeline: [AnyObject] = [AnyObject]()
    let semaphore = DispatchSemaphore(value: 1)
    let MAX_IMAGE_HEIGHT:CGFloat = 300

    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // 時間がかかる処理なのでサブスレッド(global queue)で呼ばれるべき
    func updateTimeline()
    {
        let requestHandler: TWTRNetworkCompletion = { (response: URLResponse?, data: Data?, error: Error?)  in

            if error != nil {
                print(error as Any)
            } else {
                do {
                    self.timeline.removeAll()
                    let result = try JSONSerialization.jsonObject(
                        with: data!, options: .allowFragments)

                    // show json for debug
                    // print(result)
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

        let errorHandler: ErrorHandler = {
            
            (message:String?) -> Void in
            print(message!)
        }
        
        TwitterWrapper.getInstance().updateTimeline(
            handler: requestHandler,
            errorHandler: errorHandler,
            semaphore: self.semaphore)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "読み込み")
        self.refreshControl.addTarget(self, action: #selector(TimeLineViewController.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.estimatedRowHeight = 400.0
        self.tableView.rowHeight = UITableView.automaticDimension

        self.refreshControl.beginRefreshing()
        refresh()
    }
  
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    /*
     * UIRefreshControl によって画面を縦にフリックしたあとに(=リフレッシュ)呼ばれる
     */
    @objc func refresh()
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
        cell.tweet = timeline[row] as? [String:Any]
        
        // ユーザ
        if let user = timeline[row]["user"] as? [String: Any]
        {
            cell.name?.text = user["name"] as? String
            // アイコンのURLをとってきてプロトコルをHTTPに変更
            let iconUrlString = (user["profile_image_url_https"] as! String)
            // キャッシュしているアイコンを取得
            if let cacheImage = self.config.iconCache.object(forKey: iconUrlString as AnyObject) {
                // キャッシュ画像の設定
                cell.icon.image = cacheImage
            }
            else {
                
                // アイコンはキャッシュに存在しない
                guard let iconUrl = URL(string: iconUrlString) else {
                    // urlが生成できなかった
                    return cell
                }
                
                loadImage(request: URLRequest(url: iconUrl), session: URLSession.shared,
                          cell: cell, urlString: iconUrlString,
                          function: {(image:UIImage, urlString:String) -> Void in
                            // ダウンロードしたアイコンをキャッシュする
                            self.config.iconCache.setObject(image, forKey: urlString as AnyObject)
                            // メインスレッドで表示
                            DispatchQueue.main.async {
                                cell.icon.image = image
                            }
                })
            }
        }
        
        // イメージの高さ設定をゼロ(空白行をさけるため)
        cell.imageHeightConstraint.constant = 0
        
        // ツイート内の画像(Twitterに送信された画像)
        if let entities = timeline[row]["entities"] as? [String:Any]
        {
            if let media = entities["media"] as? [AnyObject]
            {
                for mediaEntity in media
                {
                    if let mediaUrlString = mediaEntity["media_url_https"]
                    {
                        print(mediaUrlString!)
                        
                        let mediaUrl = URL(string: mediaUrlString as! String);
                        if let mediaUrl = mediaUrl
                        {
                            // イメージの高さ制約を設定
                            cell.imageHeightConstraint.constant = MAX_IMAGE_HEIGHT
                            cell.imageWidthConstraint.constant = cell.frame.width
                            
                            loadImage(
                                request: URLRequest(url: mediaUrl), session: URLSession.shared,
                                cell: cell, urlString: mediaUrlString as! String,
                                function: { (image:UIImage, urlString:String) -> Void in
                                    // メインスレッドで表示
                                    DispatchQueue.main.async {
                                        cell.mediaImage.image = image
                                    }
                            })
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func loadImage(request:URLRequest, session:URLSession, cell:TweetCell, urlString:String, function:@escaping (UIImage, String)->Void) -> Void {
        
        
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
            
            function(image, urlString)
        }
        // 画像の読み込み処理開始
        task.resume()
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
                tweetViewController.image = cell.mediaImage.image
            }
        }
    }
}
