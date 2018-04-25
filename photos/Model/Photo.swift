//
//  Photo.swift
//  photos
//
//  Created by Yogesh Kumar on 16/04/18.
//  Copyright © 2018 mycompany. All rights reserved.
//

import Foundation
import UIKit

struct Photo {
    let image: UIImage?
    let type: ImageType
    let photoID: String
}

enum ImageType {
    case thumb
    case large
}
