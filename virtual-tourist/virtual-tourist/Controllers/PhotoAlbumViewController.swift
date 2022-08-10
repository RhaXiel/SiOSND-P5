//
//  CollectionViewController.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
 
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var dataController:DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        downloadPhotoData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

    private func setupFetchedResultsController() {
       let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
      
       if let pin = pin {
           let predicate = NSPredicate(format: "pin == %@", pin)
           fetchRequest.predicate = predicate
        
           print("\(pin.latitude) \(pin.longitude)")
       }
       let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
       fetchRequest.sortDescriptors = [sortDescriptor]
       
       fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photo")
        
       fetchedResultsController.delegate = self
        print(fetchedResultsController.cacheName!)
        print(fetchedResultsController.fetchedObjects?.count ?? 0)
       do {
           try fetchedResultsController.performFetch()
       } catch {
           fatalError("Could not fetch images: \(error.localizedDescription)")
       }
   }
    
    func downloadPhotoData() {
        
        print("\(String(describing: fetchedResultsController.fetchedObjects?.count))")
                
        guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
            print("Images already downloaded")
            return
        }

        let pagesCount = Int(self.pin.pages)
        let params = SearchRequestParams(lat: pin.latitude, lon: pin.longitude)
        APIClient.getPhotos(params: params) { (photos, totalPages, error) in
            
        if photos.count > 0 {
            DispatchQueue.main.async {
                if (pagesCount == 0) {
                    self.pin.pages = Int32(Int(totalPages))
                }
                for photo in photos {
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.imageUrl = URL(string: photo.url_m ?? "https://placeholder.com/80") //There are some photos that don't include url_m!
                    newPhoto.imageData = nil
                    newPhoto.pin = self.pin
                    newPhoto.imageId = UUID().uuidString
                    
                    do {
                        try self.dataController.viewContext.save()
                    } catch {
                        print("Unable to save the photo")
                    }
                }
            }
        }
      }
    }
    
    
    @IBAction func handleCreateNewCollection(_ sender: Any) {
        guard let imageObject = fetchedResultsController.fetchedObjects else { return }
        for image in imageObject {
            dataController.viewContext.delete(image)
           do {
               try dataController.viewContext.save()
           } catch {
                print("Unable to delete images")
            }
        }
        downloadPhotoData()
    }
    
    //MARK: ViewCollection Protocol Implementation
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoViewCell", for: indexPath as IndexPath) as! PhotoAlbumViewCell
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
            print("Images already saved.")
            return cell
        }
    
        let photoData = self.fetchedResultsController.object(at: indexPath)

        
        if photoData.imageData == nil {
            newCollectionButton.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: photoData.imageUrl!) {
                    DispatchQueue.main.async {
                        photoData.imageData = imageData
                        do {
                            try self.dataController.viewContext.save()
                            
                        } catch {
                            print("error in saving image data")
                        }
                        
                        let image = UIImage(data: imageData)!
                        cell.imageView.image = image
                    }
                }
            }
            
        } else {
          if let imageData = photoData.imageData {
                let image = UIImage(data: imageData)!
                cell.imageView.image = image
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteImage(_:))))
            }
        }
        newCollectionButton.isEnabled = true
        return cell
    }
    
    func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
    }
    
    @objc func deleteImage(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        if let index = indexPath {
            print("Deleting index: \(index)!")
            let photoData = self.fetchedResultsController.object(at: index)
            self.dataController.viewContext.delete(photoData)
            try! self.dataController.viewContext.save()
       }
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath:  IndexPath?)
    {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
    
}
