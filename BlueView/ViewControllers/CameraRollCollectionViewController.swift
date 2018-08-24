//
//  CameraRollCollectionViewController.swift
//  BlueView
//
//  Created by Joe on 8/24/18.
//  Copyright © 2018 Joe. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import Photos
import VimeoNetworking
import VimeoUpload


class CameraRollCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	static let nibName = "CameraRollCollectionViewController"
	private static let collectionViewSpacing: CGFloat = 2
	
	private var videoAssets: [VIMPHAsset] = []
	private var cameraRollAssetHelper: PHAssetHelper?
	
	var sessionManager: VimeoSessionManager?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.cameraRollAssetHelper = PHAssetHelper()
		self.videoAssets = self.loadVideoAssets()
		
		//self.setupNavigationBar()
		self.setupCollectionView()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.collectionView?.indexPathsForSelectedItems?.forEach({ self.collectionView?.deselectItem(at: $0, animated: true) })
	}

	// MARK: Setup
	
	private func loadVideoAssets() -> [VIMPHAsset] {
		
		var assets = [VIMPHAsset]()
		
		let options = PHFetchOptions()
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		
		let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
		fetchResult.enumerateObjects { (object: AnyObject?, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
			if let phAsset = object as? PHAsset {
				let vimPHAsset = VIMPHAsset(phAsset: phAsset)
				assets.append(vimPHAsset)
			}
		}
		
		return assets
	}
	
	private func setupCollectionView() {
		let nib = UINib(nibName: CameraRollCollectionViewCell.nibName, bundle: nil)
		self.collectionView?.register(nib, forCellWithReuseIdentifier: CameraRollCollectionViewCell.cellIdentifier)
		
		let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
		layout?.minimumInteritemSpacing = CameraRollCollectionViewController.collectionViewSpacing
		layout?.minimumLineSpacing = CameraRollCollectionViewController.collectionViewSpacing
	}

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoAssets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraRollCollectionViewCell.cellIdentifier, for: indexPath) as! CameraRollCollectionViewCell
    
        let cameraRollAsset = self.videoAssets[indexPath.item]
		
		self.cameraRollAssetHelper?.requestImage(cell: cell, cameraRollAsset: cameraRollAsset)
		self.cameraRollAssetHelper?.requestAsset(cell: cell, cameraRollAsset: cameraRollAsset)
		
        return cell
    }

    // MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let videoAsset = self.videoAssets[indexPath.item]
		
		// Check if an error occurred when attempting to retrieve the asset
		if let error = videoAsset.error {
			self.presentAssetErrorAlert(at: indexPath, error: error)
			return
		}
		
		if AFNetworkReachabilityManager.shared().isReachable == false {
			let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: "The internet connection appears to offline."])
			self.presentOfflineErrorAlert(at: indexPath, error: error)
		}
		
		self.didSelect(videoAsset)
	}

	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		let cameraRollAsset = self.videoAssets[indexPath.item]
		self.cameraRollAssetHelper?.cancelRequests(with: cameraRollAsset)
		
	}
	// MARK: UICollectionViewFlowLayoutDelegate
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let dimension = (collectionView.bounds.size.width - CameraRollCollectionViewController.collectionViewSpacing) / 3.1
		
		return CGSize(width: dimension, height: dimension)
	}
	
	// MARK: UI Presentation
	
	private func presentAssetErrorAlert(at indexPath: IndexPath, error: NSError) {
		let alert = UIAlertController(title: "Asset Error", message: error.localizedDescription, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
			// Let the user manually reselect the cell since reload is async
			self?.collectionView?.reloadItems(at: [indexPath])
		}
		
		alert.addAction(okAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	private func presentOfflineErrorAlert(at indexPath: IndexPath, error: NSError) {
		
		let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] action in
			
			guard let strongSelf = self else { return }
			strongSelf.collectionView?.indexPathsForSelectedItems?.forEach({ strongSelf.collectionView?.deselectItem(at: $0, animated: true) })
			
		}
		let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] action in
			guard let strongSelf = self else { return }
			strongSelf.collectionView(strongSelf.collectionView!, didSelectItemAt: indexPath)
		}
		alert.addAction(cancelAction)
		alert.addAction(tryAgainAction)
		self.present(alert, animated: true, completion: nil)
		
	}
	
	func setupNavigationBar() {
		self.title = "Camera Roll"
	}
	
	func didSelect(_ asset: VIMPHAsset) {
		assertionFailure("Subclasses must override")
	}
    
}
