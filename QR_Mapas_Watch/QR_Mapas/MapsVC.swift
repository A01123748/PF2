//
//  ViewController.swift
//  MapKit
//
//  Created by Eliseo Fuentes on 9/14/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class Points: NSManagedObject {
    @NSManaged var image: Data
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
}

class Route: NSManagedObject {
    @NSManaged var name: String
}

class CustomPointAnnotation: MKPointAnnotation {
    var photo = UIImageView()
}

class MapsVC: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapa: MKMapView!
    fileprivate let manejador = CLLocationManager()
    var annotation = CustomPointAnnotation()
    var managedObjectContext: NSManagedObjectContext? = nil
    var cAnnos = [CustomPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapa.addGestureRecognizer(uilgr)
        mapa.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
            if(manager.location != nil){
                let span = MKCoordinateSpanMake(0.015, 0.015)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!), span: span)
                mapa.setRegion(region, animated: true)
            }
        }
        else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    /*func insertPin( latitude: CLLocationDegrees, longitude: CLLocationDegrees,isUpdate:Bool, measuredDistance:Double){
       
        currentLocation = CLLocation.init(latitude: latitude, longitude: longitude)
        let pin = MKPointAnnotation()
        pin.coordinate.latitude = latitude
        pin.coordinate.longitude = longitude
        let latP = String(format: "%.3f", latitude)
        let longP = String(format: "%.3f", longitude)
        
        pin.title = "Long: \(longP)º, Lat: \(latP)º"
        if(isUpdate){
            distance+=measuredDistance
        }
        let distanceP = String(format: "%.3f", distance)
        pin.subtitle = "Ditancia recorrida: \(distanceP)m"
        mapa.addAnnotation(pin)
    }*/
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapa)
            let newCoordinates = mapa.convert(touchPoint, toCoordinateFrom: mapa)
            annotation = CustomPointAnnotation()
            annotation.coordinate = newCoordinates
            
            self.performSegue(withIdentifier: "details", sender: self)
        }
    }
    
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.detailCalloutAccessoryView = self.annotation.photo
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PINDetailsVC{
            let dest = segue.destination as! PINDetailsVC
            dest.sourceViewController = self
            //dest.customPin = annotation
        }
    }
    
    func obtenerRuta(_ origen:MKMapItem, destino:MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .walking
        let indicaciones = MKDirections(request:solicitud)
        indicaciones.calculate(completionHandler: {
            (response:MKDirectionsResponse?, error:NSError?) in
            if error != nil{
                print(error)
            }
            else{
                self.muestraRuta(response!)
            }
        })
    }
    func muestraRuta(_ resp:MKDirectionsResponse){
        for ruta in resp.routes{
            mapa.add(ruta.polyline,level: MKOverlayLevel.aboveRoads)
            for paso in ruta.steps{
                print(paso.instructions)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    @IBAction func saveRoute(_ sender: AnyObject) {
        let pins = self.cAnnos
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let route = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context)
             // If appropriate, configure the new managed object.
             // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        //route.name = "Nombre de la ruta"
        let point = NSEntityDescription.insertNewObject(forEntityName: "Points", into: context) as! Points
        //let point = NSManagedObject(entity: route, insertIntoManagedObjectContext: context) as! Points
        var points = [Points]()
            for ann in pins{
                print(ann.coordinate.latitude)
                point.latitude = ann.coordinate.latitude
                point.longitude = ann.coordinate.longitude
                point.name = ann.title!
                if(ann.photo.image != nil){
                    point.image = UIImagePNGRepresentation(ann.photo.image!)!
                }
                points.append(point)
                route.setValue(point, forKey: "points")
            }

             // Save the context.
             do {
             try context.save()
                let alert = UIAlertController(title: "Save", message: "Data correctly saved", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
             } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             //print("Unresolved error \(error), \(error.userInfo)")
                let alert = UIAlertController(title: "Error", message: "Something went wrong in the save", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
             abort()
             }
        
        
        
        

    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Route", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: break
            //self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .delete: break
            //self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: break
            //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .delete: break
            //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .update: break
            //self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
        case .move: break
            //tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //self.tableView.endUpdates()
    }
    
    
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    /*func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // In the simplest, most efficient, case, reload the table view.
        //self.tableView.reloadData()
    }*/
    
    

}

