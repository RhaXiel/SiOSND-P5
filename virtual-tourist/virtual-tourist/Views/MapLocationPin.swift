//
//  MapLocationPin.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation
import MapKit

class MapLocationPin: MKPointAnnotation {
    var pin: Pin
    
    init(pin: Pin){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
