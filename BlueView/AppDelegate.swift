//
//  AppDelegate.swift
//  BlueView
//
//  Created by Joe on 8/22/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import UIKit
import VimeoNetworking
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		AFNetworkReachabilityManager.shared().startMonitoring()
		
		// Ensure init is called on launch
		NewVimeoUploader.sharedInstance?.applicationDidFinishLaunching()
		
		NetworkManager.setupAuthentication()
		
		return true
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		// This handles the redirect URL opened by Vimeo when you complete code grant authentication.
		// If your app isn't opening after you accept permissions on Vimeo, check that your app has the correct URL scheme registered.
		// See the README for more information.
		
		AuthenticationController(client: VimeoClient.sharedClient, appConfiguration: AppConfiguration.defaultConfiguration).codeGrant(responseURL: url) { result in
			
			switch result {
			case .success(result: let account):
				print("Authenticated successfully: \(account)")
			case .failure(error: let error):
				print("Failure authenticating: \(error)")
				
				let title = "Code Grant Authentication Failed"
				let message = "Make sure that your redirect URI is added to the dev portal"
				
				let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(action)
				self.window?.rootViewController?.present(alert, animated: true, completion: nil)
				print("💥" + title + ": " + message)
			}
		}
		
		return true
	}
	
	func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
		
		guard let descriptorManager = NewVimeoUploader.sharedInstance?.descriptorManager else { return }
		
		if descriptorManager.canHandleEventsForBackgroundURLSession(withIdentifier: identifier) {
			descriptorManager.handleEventsForBackgroundURLSession(completionHandler: completionHandler)
		}
	}

}
















