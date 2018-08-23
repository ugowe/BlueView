//
//  NewVimeoUploader.swift
//  BlueView
//
//  Created by Joe on 8/22/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import Foundation
import VimeoUpload
import VimeoNetworking

class NewVimeoUploader: VimeoUploader<UploadDescriptor> {
	private static var APIVersionString: String {
		return "3.4"
	}
	
	static let sharedInstance = NewVimeoUploader(backgroundSessionIdentifier: "com.vimeo.upload") { () -> String? in
		return "YOUR_OAUTH_TOKEN" // See README for details on how to obtain and OAuth token
	}
	
	// MARK: - Initialization
	
	init?(backgroundSessionIdentifier: String, accessTokenProvider: @escaping VimeoRequestSerializer.AccessTokenProvider){
		super.init(backgroundSessionIdentifier: backgroundSessionIdentifier, accessTokenProvider: accessTokenProvider, apiVersion: NewVimeoUploader.APIVersionString)
	}
}
