//
//  ImageDownloader.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 tsystem. All rights reserved.
//

import Foundation
import UIKit

struct ImageCache{
    static let MB = 1024 * 1024
}

class ImageDownloader {
    
    static let sharedManager = ImageDownloader()
    let imageOperationQueue = OperationQueue()
    
    
    let imgCache = NSCache<NSString, UIImage>()

    init() {
        imgCache.countLimit = 200
        imgCache.totalCostLimit = 200*ImageCache.MB
        imageOperationQueue.maxConcurrentOperationCount = 5
    }
    func downloadImage(_ url: URL,_ type: ImageType, photoID: String, priority: Operation.QueuePriority, completion: @escaping (Photo?,Error?)->Void) {
        
        if let image = imgCache.object(forKey: url.absoluteString as NSString) {
            let photo = Photo(image: image, type: type, photoID: photoID)
            
            DispatchQueue.main.async {
                completion(photo, nil)
            }
        
            return
        }
    
        let operation = BlockOperation(block: { [weak self] in
            do {
                
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    
                    let photo = Photo(image: image, type: type, photoID: photoID)
                    self?.imgCache.setObject(image, forKey: url.absoluteString as NSString)
                    
                    DispatchQueue.main.async {
                        completion(photo, nil)
                    }
                }
            } catch {
                
            }
        })
        operation.name = url.absoluteString
        operation.queuePriority = priority
        imageOperationQueue.addOperation(operation)
    }
    
    func updateOperationPriority(_ priority: Operation.QueuePriority, url: URL) {
        
        for operation in imageOperationQueue.operations {
            if operation.name == url.absoluteString {
                operation.queuePriority = priority
            }
        }
    }
    
    func imageForKey(_ key: String) -> UIImage?{
        if let image = imgCache.object(forKey: key as NSString) {
            return image
        }
        return nil
    }
    
}
