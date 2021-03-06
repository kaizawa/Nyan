//
//  CameraViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/08/13.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Accounts
import Social

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
        
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let semaphore = DispatchSemaphore(value: 1)
    let config:Config = Config.sharedInstance
    let captureSession = AVCaptureSession()
    var upLoading:Bool = false
    
    override func viewDidLoad()
    {
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)
        videoDevice?.unlockForConfiguration()
        
        let cameraInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(cameraInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)

        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        captureSession.addOutput(videoDataOutput)
        
        DispatchQueue.global(qos: .userInitiated).async
            {
            self.captureSession.startRunning()
        }
        activityIndicator.isHidden = true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if(!upLoading)
        {
            imageView.image = getImage(sampleBuffer: sampleBuffer)
        }
    }
    
    func getImage(sampleBuffer :CMSampleBuffer) -> UIImage {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        // ロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let rowValue:UInt32 = CGBitmapInfo.byteOrder32Little.rawValue |
            CGImageAlphaInfo.premultipliedFirst.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rowValue as UInt32)
        
        let newContext = CGContext(
            data: base, width: Int(width),
            height: Int(height),
            bitsPerComponent: Int(bitsPerCompornent),
            bytesPerRow: Int(bytesPerRow),
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue)! as CGContext
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.right)
        // アンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return image
    }
    
    func setLabel(text:String)
    {
        DispatchQueue.main.async() {

            self.label.text = text
        }
    }
    
    func handleError(msg:String) {
        
        self.setLabel(text: msg)
    }
    
    func getMediaId()
    {        
        let imageData = config.image!.jpegData(compressionQuality: 1)
        
        guard let _ = imageData else {
            self.handleError(msg: "写真データないにゃん")
            return
        }

        TwitterWrapper.getInstance().postMedia(imageData ?? Data(), success: { json in
                    let mediaId = json["media_id_string"].string
                    self.config.setMediaId(mediaId)
                }, failure: { error in
                    // 失敗時の処理
                    self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                })
    }
    
    @IBAction func takeShot(_ sender: UIBarButtonItem) {
        
        upLoading = true
        
        // 古いメディアIDを削除する
        config.userDefaults.removeObject(forKey: Config.MEDIA_ID_NAME)
        // 新しいイメージをセット
        config.setImage(self.imageView.image!)

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        // バックグラウンドでメディアIDを得る
        DispatchQueue.global().async
        {

            self.getMediaId()

            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "config")
                as! ConfigViewController
            
            DispatchQueue.main.async {

                self.present(nextView, animated: false, completion: nil)
            }
        }
    }
}
