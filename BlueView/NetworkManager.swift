//
//  NetworkManager.swift
//  BlueView
//
//  Created by Joe on 8/28/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import Foundation
import VimeoUpload
import VimeoNetworking

struct NetworkManager {
	
	static func setupAuthentication() {
		
		VimeoClient.configureSharedClient(withAppConfiguration: AppConfiguration.defaultConfiguration)
		
		// Starting the authentication process
		let authenticationController = AuthenticationController(client: VimeoClient.sharedClient, appConfiguration: AppConfiguration.defaultConfiguration)
		
		// First, we try to load a preexisting account
		let loadedAccount: VIMAccount?
		do {
			loadedAccount = try authenticationController.loadUserAccount()
		} catch let error {
			loadedAccount = nil
			print("Error loading account \(error)")
		}
		
		// If we didn't find an account to load or loading failed, we'll authenticate using client credentials
		if loadedAccount == nil {
			authenticationController.clientCredentialsGrant { (result) in
				switch result {
				case .success(result: let account):
					print("Authenticated successfully: \(account)")
				case .failure(error: let error):
					print("Failure authenticating: \(error)")
					
					let title = "Client Credentials Authentication Failed"
					let message = "Make sure that your client identifier and client secret are set correctly"
					
					let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(okAction)
					// viewController .present(alert, animated: true, completion: nil)
				}
			}
		}
	}
}
