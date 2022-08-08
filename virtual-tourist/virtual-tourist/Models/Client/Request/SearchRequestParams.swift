//
//  File.swift
//  virtual-tourist
//
//  Created by RhaXiel on 6/8/22.
//

import Foundation

struct SearchRequestParams{
    let lat: Double
    let lon: Double
    let per_page: Int = 25
    var page: Int = 0
    let format: String = "json"
    let nojsoncallback: Int = 1
    let extras: String = "url_m"
}
