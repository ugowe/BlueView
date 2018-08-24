//
//  CameraRollCollectionViewCell.swift
//  BlueView
//
//  Created by Joe on 8/24/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import UIKit
import VimeoUpload

class CameraRollCollectionViewCell: UICollectionViewCell {
	
	static let cellIdentifier = "CameraRollCellIdentifier"
	static let nibName = "CameraRollCollectionViewCell"
	
	@IBOutlet weak var cellImageView: UIImageView!
	@IBOutlet weak var fileSizeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	
	override var isSelected: Bool {
		didSet {
			if isSelected == true {
				self.cellImageView.alpha = 0.5
			} else {
				self.cellImageView.alpha = 1.0
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.clear()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.clear()
	}
	
	private func clear() {
		self.cellImageView.image = nil
		self.fileSizeLabel.text = ""
		self.durationLabel.text = ""
	}
	
}

extension CameraRollCollectionViewCell: CameraRollAssetCell {
	
	func set(image: UIImage) {
		self.cellImageView.image = image
	}
	
	func setDuration(seconds: Float64) {
		var durationString = ""
		
		if seconds > 0 {
			durationString = NSString.stringFromDuration(inSeconds: seconds) as String
		}
		
		self.durationLabel.text = durationString
	}
	
	func setFileSize(bytes: Float64) {
		var fileSizeString = ""
		
		if bytes > 0 {
			fileSizeString = NSString.stringFromFileSize(bytes: bytes) as String
		}
		
		self.fileSizeLabel.text = fileSizeString
	}
	
	func setInCloud() {
		self.fileSizeLabel.text = NSLocalizedString("iCloud", comment: "")
	}

}
