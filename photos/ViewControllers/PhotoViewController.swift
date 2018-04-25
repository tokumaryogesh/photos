//
//  PhotoViewController.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 tsystem. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    var photo: FlickrPhoto!
    var imageView = UIImageView()
    let activityIndicator = UIActivityIndicatorView()

    
    convenience init(photo: FlickrPhoto) {
        self.init()
        self.photo = photo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    
    func prepareView() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        imageView.frame = CGRect(x: 0, y: 40, width: SCREEN.width, height: SCREEN.height-64)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 1.0
        self.view.addSubview(imageView)
        
        if let largeImageURL = photo.largeImageURL {
            if let image =  ImageDownloader.sharedManager.imageForKey(largeImageURL.absoluteString) {
                imageView.image = image
            } else {
                activityIndicator.activityIndicatorViewStyle = .whiteLarge
                activityIndicator.color = UIColor.orange
                activityIndicator.center = self.view.center
                self.view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                ImageDownloader.sharedManager.downloadImage(largeImageURL, .large, photoID: photo.photoID, priority: .high) { [weak self] (photo, error) in
                    if let photo = photo {
                        self?.imageView.image = photo.image
                        self?.activityIndicator.stopAnimating()
                        self?.activityIndicator.removeFromSuperview()
                    }
                }
                
                if let thumbURL = photo.thumbnail {
                    if let image = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){
                        imageView.image = image
                    }
                }
            }
        }
        
        let frame = CGRect(x: SCREEN.width - 64, y: 30, width: 38, height: 38)
        let crossButton = UIButton(frame: frame)
        crossButton.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
        crossButton.addTarget(self, action: #selector(crossbuttonPressed(_:)), for: .touchUpInside)
        self.view.addSubview(crossButton)
    }
    
    func frameForPhotoInSize(_ size: CGSize) ->  CGRect{
        if let thumbURL = photo.thumbnail {
            if let image = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){
                let size = image.size
                let frame = AVMakeRect(aspectRatio: size, insideRect: imageView.frame)
                return frame
            }
        }
        return CGRect.zero
    }
    
    @objc func crossbuttonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK :- ViewController Transition protocol

extension PhotoViewController: PhotoTransitionProtocol {
    
    func imageWindowFrame() -> CGRect {
        if let thumbURL = photo.thumbnail {
            if let image = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){
                let size = image.size
                let frame = frameForPhotoInSize(size)
                return frame
            }
        }
        return CGRect.zero
    }
    
    func transitionWillStart() {
        imageView.alpha = 0.0
    }
    
    func transitionDidEnd() {
        imageView.alpha = 1.0
    }
        
}
