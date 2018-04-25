//
//  GalleryViewController.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 mycompany. All rights reserved.
//

import UIKit
import AVFoundation

enum GridLayout {
    case small  // 3 Photos in a row
    case large  // 2 photos in a row
}


class GalleryViewController: UIViewController {
    
    let searchBar = UISearchBar()
    var photoCollectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!
    var selectedLayout = GridLayout.small
    var photoSource = FlickrSearchResults(searchTerm: "", searchResults: [], pages: 0)
    var isLoading = false
    
    let animationController = AnimatorController()
    var selectedIndexPath: IndexPath?
    let activityIndicator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func prepareView() {
        
        let frame = CGRect(x: 0, y: 108, width: SCREEN.width, height: SCREEN.height-108)
        flowLayout = UICollectionViewFlowLayout()
        updateCollectionViewEstimatedItemSizeForLayout(flowLayout)

        photoCollectionView =  UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        self.view.addSubview(photoCollectionView)
        
        searchBar.frame = CGRect(x: 0, y: 64, width: SCREEN.width, height: 44)
        searchBar.delegate = self
        searchBar.placeholder = "Search for Images"
        self.view.addSubview(searchBar)
        
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        photoCollectionView.backgroundColor = UIColor.white
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = false
        activityIndicator.center = self.view.center
        activityIndicator.isHidden = true
        self.view.addSubview(activityIndicator)
    }
    
    @IBAction func layoutBarButtonClicked(_ sender:UIBarButtonItem) {
        let alertController = UIAlertController(title: "Layout", message: "hi", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let largeAction = UIAlertAction(title: "Large", style: .default) { [weak self](action) in
            self?.updateLayout(.large)
        }
        
        let smallAction = UIAlertAction(title: "Small", style: .default) { [weak self] (action) in
            self?.updateLayout(.small)
        }
        
        alertController.addAction(largeAction)
        alertController.addAction(smallAction)
        self.show(alertController, sender: self)
    }
    
    func updateCollectionViewEstimatedItemSizeForLayout(_ layout: UICollectionViewFlowLayout) {
        
        var noOfCellsPerRow: CGFloat = 0
        let spacing: CGFloat = 10
        if selectedLayout == .small {
            noOfCellsPerRow = 3
        } else {
            noOfCellsPerRow = 2
        }
        let size = (SCREEN.width - ((noOfCellsPerRow)*spacing))/noOfCellsPerRow
        layout.estimatedItemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    func updateLayout(_ gridLayout: GridLayout) {
        if selectedLayout != gridLayout {
            selectedLayout = gridLayout
            updateCollectionViewEstimatedItemSizeForLayout(flowLayout)
            photoCollectionView.reloadData()
        }
    }
    
}

// MARK:- CollectionView DataSource

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoSource.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.displayPhoto(photoSource.searchResults[indexPath.row])
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < photoSource.searchResults.count {
            if let thumbUrl = photoSource.searchResults[indexPath.row].thumbnail {
                ImageDownloader.sharedManager.updateOperationPriority(.normal, url: thumbUrl)
            }
        }
    }
    
}

// MARK:- CollectionView Delegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + photoCollectionView.frame.size.height >= photoCollectionView.contentSize.height - FLICKR.bottomTriggerForLoadMore && isLoading == false {
            if photoSource.pages < photoSource.searchResults.count/20 {
                if let text = searchBar.text {
                    isLoading = true
                    requestdataFromFlickr(text)
                }
            } else {
                isLoading = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        self.selectedIndexPath = indexPath
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.row <= photoSource.searchResults.count {
                let photo = photoSource.searchResults[selectedIndexPath.row]
                if let thumbURL = photo.thumbnail {
                    if let _ = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString) {
                        let vc = PhotoViewController(photo: photo)
                        vc.transitioningDelegate = self
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}

// MARK:- UISearchBar Delegate

extension GalleryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        photoSource = FlickrSearchResults(searchTerm: "", searchResults: [], pages: 0)
        photoCollectionView.reloadData()
        
        if let text = searchBar.text {
            requestdataFromFlickr(text)
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        searchBar.resignFirstResponder()

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK:- Pagination

extension GalleryViewController {
  
    func requestdataFromFlickr(_ searchText: String) {
        
        guard let url = requestURLForFlickr(searchText) else {
            return
        }
        NetworkManager.sharedManager.searchFlickrForText(searchText, url: url) { [weak self] (result, error) in
            self?.activityIndicator.isHidden = true
            self?.activityIndicator.stopAnimating()
            self?.isLoading = false
            if error == nil {
                if let result = result {
                    self?.photoSource.searchResults.append(contentsOf: result.searchResults)
                    self?.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    
    func requestURLForFlickr(_ searchText: String) -> URL? {
        guard let escapedTerm = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        // Records perpage = FLIKR.perpageRecords
        let page = (photoSource.searchResults.count / FLICKR.perPageRecords)+1
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FLICKR.apikey)&text=\(escapedTerm)&per_page=\(FLICKR.perPageRecords)&format=json&nojsoncallback=1&page=\(page)"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
}

// MARK :- ViewController Transition protocol

extension GalleryViewController: PhotoTransitionProtocol {
    
    func imageWindowFrame() -> CGRect {
        
        if let indexPath = selectedIndexPath {
            let attributes = photoCollectionView.layoutAttributesForItem(at: indexPath)
            let cellRect = attributes!.frame
            let frame = photoCollectionView.convert(cellRect, to: self.view)
           
            let photo =  self.photoSource.searchResults[indexPath.row]
            if let thumbURL = photo.thumbnail {
                if let image = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){
                    let size = image.size
                    let newFrame = AVMakeRect(aspectRatio: size, insideRect: frame)
                    return newFrame
                }
            }
        }
        return CGRect.zero
    }
    
    func transitionWillStart() {
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.row <= photoSource.searchResults.count {
                if let cell = photoCollectionView.cellForItem(at: selectedIndexPath) as? PhotoCell {
                    cell.imageView.alpha = 0.0
                }
            }
        }

    }
    
    func transitionDidEnd() {
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.row <= photoSource.searchResults.count {
                if let cell = photoCollectionView.cellForItem(at: selectedIndexPath) as? PhotoCell {
                    cell.imageView.alpha = 1.0
                }
            }
        }
    }

}

extension GalleryViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.row <= photoSource.searchResults.count {
                let photo = photoSource.searchResults[selectedIndexPath.row]
                
                if let thumbURL = photo.thumbnail {
                    if let image = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){
                        animationController.setupPhotoTransition(image: image, fromDelegate: self, toDelegate: presented as! PhotoTransitionProtocol)
                        animationController.reverse = false
                        return animationController
                    }
                }
            }
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.row <= photoSource.searchResults.count {
                let photo = photoSource.searchResults[selectedIndexPath.row]
                if let thumbURL = photo.thumbnail {
                    if let _ = ImageDownloader.sharedManager.imageForKey(thumbURL.absoluteString){                    animationController.reverse = true
                    return animationController
                    }
                }
            }
        }
        return nil
    }
}


