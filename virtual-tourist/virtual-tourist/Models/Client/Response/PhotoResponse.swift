//
//  PhotoResponse.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation
import UIKit

struct SearchPhotoResponse: Codable{
    let photos: PhotosResponse
    let stat: String
}

struct PhotosResponse: Codable{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoResponse]
}

struct PhotoResponse: Codable {
    var photoImage: UIImage?
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_m: String?
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case url_m = "url_m"
    }
}
