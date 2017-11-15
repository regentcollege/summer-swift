//
//  PlayerViewController.swift
//  PlayerKit
//
//  Created by King, Gavin on 3/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation

class VideoViewController: UIViewController, PlayerDelegate
{
    var videoUrl: URL?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let player = RegularPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.delegate = self
        
        self.addPlayerToView()
        
        self.player.set(AVURLAsset(url: self.videoUrl!))
    }
    
    // MARK: Setup
    
    private func addPlayerToView()
    {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPlayButton()
    {
        if self.player.playing {
            self.player.pause()
            playButton.setTitle("Resume", for: .normal)
        }
        else {
            self.player.play()
            playButton.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func didChangeSliderValue()
    {
        let value = Double(self.slider.value)
        
        let time = value * self.player.duration
        
        self.player.seek(to: time)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: VideoPlayerDelegate
    
    func playerDidUpdateState(player: Player, previousState: PlayerState)
    {
        self.activityIndicator.isHidden = true
        
        switch player.state
        {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            player.play()
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player)
    {
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false
        {
            self.slider.value = Float(ratio)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = Int((player.bufferedTime / player.duration) * 100)
        if ratio == 100 {
            self.label.text = ""
            return
        }
        self.label.text = "Buffer: \(ratio)%"
    }
}

