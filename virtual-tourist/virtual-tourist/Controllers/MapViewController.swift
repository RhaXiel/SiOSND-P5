//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var labelView: UILabel!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    let regionKey: String = "regionKey"

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getSavedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         refreshData()
     }
    
    
    @IBAction func handleMapLongPress(_ sender: UILongPressGestureRecognizer) {
        switch  sender.state
        {
        case .began:
            labelView.textColor = .orange
            labelView.text = "Release to add a location"
        case .ended:
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            saveGeoCoordination(from: locationCoordinate)
            labelView.textColor = .systemGray
            labelView.text = "Press and hold to add a location"
            
        default:
            return
        }
    }
        
    func copyLocation(_ annotation: MKPointAnnotation) {
        
        let location = Pin(context: dataController.viewContext)
        location.creationDate = Date()
        location.longitude = annotation.coordinate.longitude
        location.latitude = annotation.coordinate.latitude
        location.locationName = annotation.title
        location.country = annotation.subtitle
        location.pages = 0
        try? dataController.viewContext.save()
        let annotationPin = MapLocationPin(pin: location)
        self.mapView.addAnnotation(annotationPin)
        
    }
    
    func saveGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.title = placemark.name ?? "No named place"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.copyLocation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
        photoAlbumViewController.dataController = dataController
        let pinAnnotation: MapLocationPin = sender as! MapLocationPin
        photoAlbumViewController.pin = pinAnnotation.pin
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
        let pinAnnotation = annotation as! MapLocationPin
        pinAnnotation.title = pinAnnotation.pin.locationName
        pinAnnotation.subtitle = pinAnnotation.pin.country
    
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
 
    func saveMapLocation() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: regionKey)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveMapLocation()
    }
    
    func getSavedLocation() {
        if let mapRegin = UserDefaults.standard.dictionary(forKey: regionKey) {
            let location = mapRegin as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {
                return
            }
        if let annotation = view.annotation as? MKPointAnnotation {
            do {
                let predicate = NSPredicate(format: "longitude = %@ AND latitude = %@", argumentArray: [annotation.coordinate.longitude, annotation.coordinate.latitude])
                let pindata = try dataController.fetchLocation(predicate)!
                let annotationPin = MapLocationPin(pin: pindata)
                self.performSegue(withIdentifier: "photoAlbumSegue", sender: annotationPin)
            } catch {
                print("An error occured when trying to view the location. \(error.localizedDescription)")
            }
        }
        
    }
    
}

extension MapViewController: NSFetchedResultsControllerDelegate {
   
   func refreshData() {
       self.mapView.removeAnnotations(self.mapView.annotations)
       
       let request: NSFetchRequest<Pin> = Pin.fetchRequest()
       let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
       request.sortDescriptors = [sortDescriptor]
          
       dataController.viewContext.perform {
         do {
           let pins = try self.dataController.viewContext.fetch(request)
           self.mapView.addAnnotations(pins.map { pin in MapLocationPin(pin: pin) })
           
           } catch {
               print("Error while fetching location data: \(error.localizedDescription)")
           }
       }
       
   }
}
