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

class VideoViewController: UIViewController, PlayerDelegate {
	
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	private let player = RegularPlayer()
	var videoObject: VIMVideo?
//	{
//		didSet {
//			self.configurePlayerView()
//		}
//	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		player.delegate = self

		self.addPlayerToView()
		configurePlayerView()

//		let videoFile = videoObject?.files as! [[String:Any]]
//		let firstVideoFile = videoFile[1]
//		let videoLink = firstVideoFile["link"] as! String
//		print(videoLink)
//		let videoURL = URL(string: videoLink)
//		self.player.set(AVURLAsset(url: videoURL!))
		
//		let videoURL = URL(string: "https://player.vimeo.com/external/286220548.hd.mp4?s=f9d21d0b3d3a3e6140d7dff53cad256876cccac3&profile_id=174&oauth2_token_id=1107342387")
//		self.player.set(AVURLAsset(url: videoURL!))
		
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
		guard let videoObject = self.videoObject else { return }
		let videoRequest = Request<VIMVideo>(path: videoObject.uri ?? "")
		VimeoClient.sharedClient.request(videoRequest, completion: { result in
			switch result {
			case .success(let result):
				print(result.json)
				print(result.model.files?.first)
			case .failure(let error):
				print(error)
			}
		})
	}

	@IBAction func tappedPlay(_ sender: Any) {
		self.player.playing ? self.player.pause() : self.player.play()
		let playButtonTitle = self.player.playing ? "Pause" : "Play"
		self.playButton.setTitle(playButtonTitle, for: .normal)
	}
	
	@IBAction func changeSliderValue(_ sender: Any) {
		let value = Double(self.slider.value)
		let time = value * self.player.duration
		self.player.seek(to: time)
	}


	// MARK: VideoPlayerDelegate
	
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
//		self.playButton.isSelected = player.playing
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



















