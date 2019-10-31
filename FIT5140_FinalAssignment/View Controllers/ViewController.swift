//
//  ViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        // background video
        setUpVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func setUpElements() {
        Styles.styleFilledButton(signUpButton)
        Styles.styleHollowButton(loginButton)
    }
    
    func setUpVideo() {
        let bundlePath = Bundle.main.path(forResource: "video", ofType: "mp4")
        
        guard bundlePath != nil
            else {
            return
        }
        
        // Create URL
        let url = URL(fileURLWithPath: bundlePath!)
        // Create item
        let item = AVPlayerItem(url: url)
        //Create player
        videoPlayer = AVPlayer(playerItem: item)
        //Create layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        videoPlayerLayer?.frame = CGRect(
        x: -self.view.frame.size.width*1.5,
        y: 0,
        width: self.view.frame.size.width*4,
        height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        videoPlayer?.playImmediately(atRate: 0.8)
        
    }


}

