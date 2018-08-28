//
//  VideoTableViewController.swift
//  BlueView
//
//  Created by Joe on 8/22/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import UIKit
import VimeoNetworking
import VimeoUpload
import PromiseKit

class VideoTableViewController: UITableViewController {
	
	@IBOutlet weak var logInButton: UIBarButtonItem!
	@IBOutlet weak var uploadButton: UIBarButtonItem!
	
	var videoArray: [VIMVideo] = [] {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	private var accountObservationToken: ObservationToken?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupAccountObservation()
		self.updateLoginButton()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		//self.clearsSelectionOnViewWillAppear = true
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	// MARK: - Setup
	
	private func setupAccountObservation() {
		
		// This allows us to fetch a new list of items whenever the current account changes (on Login or Logout events)
		self.accountObservationToken = NetworkingNotification.authenticatedAccountDidChange.observe(observationHandler: { [weak self] notification in
			
			guard let strongSelf = self else { return }
			
			let request: Request<[VIMVideo]>
			if VimeoClient.sharedClient.currentAccount?.isAuthenticatedWithUser() == true {
				request = Request<[VIMVideo]>(path: "/me/videos")
			} else {
				request = Request<[VIMVideo]>(path: "/channels/staffpicks/videos")
			}
			
			let _ = VimeoClient.sharedClient.request(request) { [weak self] result in
				guard let strongSelf = self else { return }
				
				switch result {
				case .success(result: let response):
					strongSelf.videoArray = response.model
					
					if let nextPageRequest = response.nextPageRequest {

						print("Starting next page request")
						let _ = VimeoClient.sharedClient.request(nextPageRequest) { [weak self] result in

							guard let strongSelf = self else { return }
							if case .success(let response) = result {
								print("Next page request completed")
								strongSelf.videoArray.append(contentsOf: response.model)
								strongSelf.tableView.reloadData()
							}
						}
					}
				case .failure(error: let error):
					let title = "Video Request Failed"
					let message = "\(request.path) could not be loaded: \(error.localizedDescription)"
					let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
					let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(OKAction)
					strongSelf.present(alert, animated: true, completion: nil)
				}
			}
			
			strongSelf.navigationItem.title = request.path
			strongSelf.updateLoginButton()
		})
	}
	
	private func updateLoginButton() {
		if VimeoClient.sharedClient.currentAccount?.isAuthenticatedWithUser() == true {
			self.logInButton.title = "Log Out"
		} else {
			self.logInButton.title = "Log In"
		}
	}
	
	
	@IBAction func tappedLogIn(_ sender: Any) {
		
		// If the user is logged in, the button logs them out.
		// If the user is logged out, the button launches the code grant authorization page
		
		let authenicationController = AuthenticationController(client: VimeoClient.sharedClient, appConfiguration: AppConfiguration.defaultConfiguration)
		
		authenicationController.accessToken(token: Secrets.accessToken) { account in
			print(account)
		}
		
//		if VimeoClient.sharedClient.currentAccount?.isAuthenticatedWithUser() == true {
//			do {
//				try authenicationController.logOut()
//			} catch let error as NSError {
//				let title = "Couldn't Log Out"
//				let message = "Logging out failed: \(error.localizedDescription)"
//				let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//				let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//				alert.addAction(OKAction)
//				self.present(alert, animated: true, completion: nil)
//			}
//		} else {
//			let URL = authenicationController.codeGrantAuthorizationURL()
//			UIApplication.shared.open(URL, options: [:], completionHandler: nil)
//		}
		
	}
	
	@IBAction func tappedUpload(_ sender: Any) {
		let cameraRollVC = CameraRollCollectionViewController(nibName: CameraRollCollectionViewController.nibName, bundle: Bundle.main)
		self.present(cameraRollVC, animated: true, completion: nil)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.videoArray.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
		
		let video = self.videoArray[indexPath.row]
		cell.textLabel!.text = video.name
		cell.textLabel?.textColor = .blue
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showVideo" ,
			let destinationController = segue.destination as? VideoViewController ,
			let indexPath = self.tableView.indexPathForSelectedRow {
			let selectedVideo = self.videoArray[indexPath.row]
			let files = selectedVideo.files
			destinationController.videoObject = selectedVideo
		}
	}
	

	
}
