//
//  VimeoClient+Shared.swift
//  BlueView
//
//  Created by Joe on 8/22/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import Foundation
import VimeoUpload
import VimeoNetworking

/// Extend app configuration to provide a default configuration
extension AppConfiguration {
	
	/// The default configuration to use for this application, populate your client key, secret, and scopes.
	/// Also, don't forget to set up your application to receive the code grant authentication redirect, see the README for details.

	static let defaultConfiguration = AppConfiguration(clientIdentifier: clientIdentifier, clientSecret: clientSecret, scopes: [.Public, .Private, .Interact], keychainService: "")
}

/// Extend vimeo client to provide a default client
extension VimeoClient
{
	/// The default client this application should use for networking, must be authenticated by an `AuthenticationController` before sending requests
	static let defaultClient = VimeoClient(appConfiguration: AppConfiguration.defaultConfiguration)
}
