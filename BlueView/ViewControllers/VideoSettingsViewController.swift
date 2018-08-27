//
//  VideoSettingsViewController.swift
//  BlueView
//
//  Created by Joe on 8/24/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import VimeoUpload
import VimeoNetworking


class VideoSettingsViewController: UIViewController, UITextViewDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var playerView: UIView!
	
	private var videoAsset: VIMPHAsset
	private var video: VIMVideo?
	private var videoSettings: VideoSettings?
	
	private var operation: ExportSessionExportCreateVideoOperation?
	private var descriptor: Descriptor?
	
	private var url: URL?
	private var task: URLSessionDataTask?
	
	static let UploadInitiatedNotification = "VideoSettingsViewControllerUploadInitiatedNotification"
	static let NibName = "VideoSettingsViewController"
	private static let PreUploadViewPrivacy = "pre_upload"
	
	private var hasTappedUpload: Bool {
		get {
			return self.videoSettings != nil
		}
	}
	
	init(asset: VIMPHAsset) {
		self.videoAsset = asset
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		// Do not cancel operation, it will delete the source file
		self.task?.cancel()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//self.edgesForExtendedLayout = []
		self.setupNavigationBar()
		//self.setupAndStartOperation()
		
		
	}
	
	private func setupNavigationBar() {
		self.title = "Video Settings"
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(VideoSettingsViewController.tappedCancel(_:)))
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: UIBarButtonItemStyle.done, target: self, action: #selector(VideoSettingsViewController.tappedUpload(_:)))
	}
	
	private func setupAndStartOperation() {
		
		guard let sessionManager = NewVimeoUploader.sharedInstance?.foregroundSessionManager else { return }
		
		let videoSettings = self.videoSettings
		let phAsset = self.videoAsset.phAsset
		let operation = ExportSessionExportCreateVideoOperation(phAsset: phAsset, sessionManager: sessionManager, videoSettings: videoSettings)
		
		operation.downloadProgressBlock = { (progress: Double) -> Void in
			print(String(format: "Download progress: %.2f", progress)) // TODO: Dispatch to main thread
		}
		
		operation.exportProgressBlock = { (exportSession: AVAssetExportSession, progress: Double) -> Void in
			print(String(format: "Export progress: %.2f", progress))
		}
		
		operation.completionBlock = { [weak self] () -> Void in
			DispatchQueue.main.async(execute: { [weak self] () -> Void in
				guard let strongSelf = self else { return }
				if operation.isCancelled == true { return }
				
				if operation.error == nil {
					strongSelf.url = operation.url!
					strongSelf.video = operation.video!
					strongSelf.startUpload()
				}
				
				if strongSelf.hasTappedUpload == true {
					if let error = operation.error {
						//strongSelf.activityIndicatorView.stopAnimating()
						strongSelf.presentOperationErrorAlert(with: error)
					} else {
						if let video = strongSelf.video, let viewPrivacy = video.privacy?.view, viewPrivacy != type(of: strongSelf).PreUploadViewPrivacy {
							NotificationCenter.default.post(name: Notification.Name(rawValue: VideoSettingsViewController.UploadInitiatedNotification), object: strongSelf.video)
							strongSelf.startUpload()
							//strongSelf.activityIndicatorView.stopAnimating()
							//strongSelf.navigationController?.dismiss(animated: true, completion: nil)
						} else {
							strongSelf.applyVideoSettings()
						}
					}
				}
			})
		}
		self.operation = operation
		self.operation?.start()
	}
	
	private func startUpload() {
		guard let url = self.url else { return }
		guard let video = self.video else { return }
		let assetIdentifier = self.videoAsset.identifier
		
		let descriptor = UploadDescriptor(url: url, video: video)
		descriptor.identifier = assetIdentifier
		NewVimeoUploader.sharedInstance?.uploadVideo(descriptor: descriptor)
	}
	
	// MARK: Actions
	
	@objc func tappedCancel(_ sender: UIBarButtonItem) {
		self.operation?.cancel()
		//self.activityIndicatorView.stopAnimating()
		// _ = self.navigationController?.popViewController(animated: true)
		if let videoURI = self.video?.uri {
			NewVimeoUploader.sharedInstance?.cancelUpload(videoUri: videoURI)
		}
	}
	
	@objc func tappedUpload(_ sender: UIBarButtonItem) {
		let title = self.titleTextField.text
		let description = self.descriptionTextView.text
		self.videoSettings = VideoSettings(title: title, description: description, privacy: "nobody", users: nil, password: nil)
		
		if self.operation?.state == .executing {
			self.operation?.videoSettings = self.videoSettings
			// Listen for operation completion, dismiss
			// self.activityIndicatorView.startAnimating()
		} else if let error = self.operation?.error {
			self.presentOperationErrorAlert(with: error)
		} else {
			if let video = self.video, let viewPrivacy = video.privacy?.view, viewPrivacy != VideoSettingsViewController.PreUploadViewPrivacy {
				NotificationCenter.default.post(name: Notification.Name(rawValue: type(of: self).UploadInitiatedNotification), object: video)
				
				self.dismiss(animated: true, completion: nil)
			} else {
				// self.activityIndicatorView.startAnimating()
				self.applyVideoSettings()
			}
		}
	}
	
	// MARK: UITextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		self.descriptionTextView.becomeFirstResponder()
		
		return false
	}
	
	// MARK: UI Presentation
	
	private func presentOperationErrorAlert(with error: NSError) {
		// TODO: check error.code == AVError.DiskFull.rawValue and message appropriately
		// TODO: check error.code == AVError.OperationInterrupted.rawValue (app backgrounded during export)
		
		let alert = UIAlertController(title: "Operation Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { [weak self] (action) -> Void in
			_ = self?.navigationController?.popViewController(animated: true)
		})
		let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { [weak self] (action) -> Void in
			//self?.activityIndicatorView.startAnimating()
			self?.setupAndStartOperation()
		})
		alert.addAction(cancelAction)
		alert.addAction(tryAgainAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	private func presentVideoSettingsErrorAlert(with error: NSError) {
		let alert = UIAlertController(title: "Video Settings Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { [weak self] (action) -> Void in
			_ = self?.navigationController?.popViewController(animated: true)
		})
		let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: { [weak self] (action) -> Void in
			//self?.activityIndicatorView.startAnimating()
			self?.applyVideoSettings()
		})
		alert.addAction(cancelAction)
		alert.addAction(tryAgainAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	// MARK: Private API
	
	private func applyVideoSettings() {
		guard let videoURI = self.video?.uri, let videoSettings = self.videoSettings else {
			let alert = UIAlertController(title: "Cannot Upload Video", message: "Check the project target", preferredStyle: .alert)
			let OKAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
				//self.activityIndicatorView.stopAnimating()
			}
			alert.addAction(OKAction)
			self.present(alert, animated: true, completion: nil)
			return
		}
		
		do {
			self.task = try NewVimeoUploader.sharedInstance?.foregroundSessionManager.videoSettingsDataTask(videoUri: videoURI, videoSettings: videoSettings, completionHandler: { [weak self] (video, error) -> Void in
				
				self?.task = nil
				
				DispatchQueue.main.async(execute: { [weak self] () -> Void in
					guard let strongSelf = self else { return }
					//strongSelf.activityIndicatorView.stopAnimating()
					
					if let error = error {
						strongSelf.presentVideoSettingsErrorAlert(with: error)
					} else {
						NotificationCenter.default.post(name: Notification.Name(rawValue: VideoSettingsViewController.UploadInitiatedNotification), object: video)
						
						strongSelf.dismiss(animated: true, completion: nil)
					}
				})
			})
			
			self.task?.resume()
		} catch let error as NSError {
			//self.activityIndicatorView.stopAnimating()
			self.presentVideoSettingsErrorAlert(with: error)
		}
	}
}


















