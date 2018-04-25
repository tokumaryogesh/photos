//
//  FlickrSearchResults.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 tsystem. All rights reserved.
//

import Foundation

struct FlickrSearchResults {
    let searchTerm : String
    var searchResults : [FlickrPhoto]
    let pages: Int
}
