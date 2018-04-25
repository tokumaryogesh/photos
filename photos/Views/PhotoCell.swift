//
//  PhotoCell.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 mycompany. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var photo: FlickrPhoto?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.backgroundColor = UIColor.black
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayPhoto(_ photoData: FlickrPhoto) {
        imageView.frame = CGRect(origin: .zero, size: self.frame.size)
        
        self.photo = photoData
        
        self.imageView.image = #imageLiteral(resourceName: "placeholder_cover")
        imageView.contentMode = .scaleAspectFill
        
        if let thumbImage = ImageDownloader.sharedManager.imageForKey((photoData.thumbnail?.absoluteString)!) {
            self.imageView.image = thumbImage
            imageView.contentMode = .scaleAspectFit
        }
         else if let thumbURL = photoData.thumbnail {
            ImageDownloader.sharedManager.downloadImage(thumbURL, .thumb, photoID: photoData.photoID, priority: .veryHigh) { [weak self] (photoData, error) in
                if let photoData = photoData, let weakself = self {
                    if photoData.photoID == weakself.photo?.photoID {
                        weakself.imageView.image = photoData.image
                        weakself.imageView.contentMode = .scaleAspectFit
                    }
                }
            }
        }
    }
    
}
