//
//  VideoViewController.swift
//  BlueView
//
//  Created by Joe on 8/22/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import Foundation
import UIKit
import PlayerKit
import VimeoUpload
import VimeoNetworking
import AVFoundation

class VideoViewController: UIViewController {
	
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	private let player = RegularPlayer()
	var videoObject: VIMVideo? {
		didSet {
			self.configurePlayerView()
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		player.delegate = self
		self.addPlayerToView()
		let videoLink = videoObject?.link
//		self.player.set(AVURLAsset(url: videoLink))
		
	}
	
	// MARK: Setup
	
	private func addPlayerToView() {
		player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		player.view.frame = self.view.bounds
		self.view.insertSubview(player.view, at: 0)
	}

	// MARK: Actions
	
	

	
	func configurePlayerView() {
		// Update the user interface for the video object
	}

	@IBAction func tappedPlay(_ sender: Any) {
		self.player.playing ? self.player.pause() : self.player.play()
	}
	
	@IBAction func changeSliderValue(_ sender: Any) {
		let value = Double(self.slider.value)
		let time = value * self.player.duration
		self.player.seek(to: time)
	}
}

// MARK: VideoPlayerDelegate

extension VideoViewController: PlayerDelegate {
	
	func playerDidUpdateState(player: Player, previousState: PlayerState) {
		self.activityIndicator.isHidden = true
		switch player.state {
		case .loading:
			self.activityIndicator.isHidden = false
		case .ready:
			break
		case .failed:
			print("🚫 \(String(describing: player.error))")
		}
	}
	
	func playerDidUpdatePlaying(player: Player) {
		self.playButton.isSelected = player.playing
	}
	
	func playerDidUpdateTime(player: Player) {
		guard player.duration > 0 else { return }
		let ratio = player.time / player.duration
		if self.slider.isHighlighted == false {
			self.slider.value = Float(ratio)
		}
	}
	
	func playerDidUpdateBufferedTime(player: Player) {
		guard player.duration > 0 else { return }
		let ratio = Int((player.bufferedTime / player.duration) * 100)
		// self.bufferedTimeLabel.text = "Buffer: \(ratio)%"
	}
	
	
}



















