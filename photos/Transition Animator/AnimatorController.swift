//
//  AnimatorController.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 tsystem. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoTransitionProtocol {
    func transitionWillStart()
    func imageWindowFrame() -> CGRect
    func transitionDidEnd()
}


class AnimatorController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var image: UIImage?
    private var fromDelegate: PhotoTransitionProtocol?
    private var toDelegate: PhotoTransitionProtocol?
    var reverse: Bool = false
    
    
    // MARK: Setup Methods
    
    func setupPhotoTransition(image: UIImage, fromDelegate: PhotoTransitionProtocol, toDelegate: PhotoTransitionProtocol){
       
        self.image = image
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 2: Get view controllers involved
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        toDelegate?.transitionWillStart()
        fromDelegate?.transitionWillStart()

        
        // 3: Set the destination view controllers frame
        toVC.view.frame = (fromVC.view.frame)

        // 4: Create transition image view
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFill
        // Handling present/Dismiss
        if reverse {
            imageView.frame = (toDelegate == nil) ? CGRect.zero : toDelegate!.imageWindowFrame()
        } else {
            imageView.frame = (fromDelegate == nil) ? CGRect.zero : fromDelegate!.imageWindowFrame()
        }
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)

        
        let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        fromSnapshot?.frame = fromVC.view.frame
        containerView.addSubview(fromSnapshot!)
        
        let toSnapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        toSnapshot?.backgroundColor = UIColor.black
        toSnapshot?.frame = fromVC.view.frame
        containerView.addSubview(toSnapshot!)
        toSnapshot?.alpha = 0
        
        containerView.bringSubview(toFront: imageView)
        
        var toFrame: CGRect!
        if reverse {
             toFrame = (fromDelegate == nil) ? CGRect.zero : fromDelegate!.imageWindowFrame()
        } else {
            toFrame = (toDelegate == nil) ? CGRect.zero : toDelegate!.imageWindowFrame()
        }
        
        
        // 8: Animate change
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            toSnapshot?.alpha = 1
            imageView.frame = toFrame
            
        }, completion:{ [weak self] (finished) in
            
            if finished {
                self?.toDelegate?.transitionDidEnd()
                self?.fromDelegate?.transitionDidEnd()
            }
            
            imageView.removeFromSuperview()
            fromSnapshot?.removeFromSuperview()
            toSnapshot?.removeFromSuperview()
            
            if !transitionContext.transitionWasCancelled {
                containerView.addSubview(toVC.view)
            }
            else {

            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
 
        })
 
        
    }
    
 
}

