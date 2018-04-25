//
//  Constant.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 mycompany. All rights reserved.
//

import Foundation
import UIKit

struct SCREEN {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    static let size = UIScreen.main.bounds.size
}

struct FLICKR {
    static let apikey = "API_KEY_FLICKR"
    static let perPageRecords = 30
    static let bottomTriggerForLoadMore: CGFloat = 100 //px
}

struct CustomError {
    static let title = "Snap Seeker"
}
