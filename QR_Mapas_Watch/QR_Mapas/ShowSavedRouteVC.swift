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


class ShowSavedRouteVC: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapa: MKMapView!
    fileprivate let manejador = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext? = nil
    var cAnnos = [CustomPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
        mapa.delegate = self
        self.configureView()
    }
    
    func configureView() {
        if let detail = self.detailItem {
            print(self.detailItem?.name.description)
            //print(self.detailItem?.points)
            //print(self.detailItem?.value(forKey: "points"))
            let ps = self.detailItem?.value(forKey: "points") as! NSOrderedSet
            var origen:MKMapItem
            var destino:MKMapItem
            print(ps.count)
            
            let span = MKCoordinateSpanMake(0.015, 0.015)
            let origenCoor = CLLocationCoordinate2DMake( CLLocationDegrees((ps[0] as! NSManagedObject).value(forKey: "latitude")as! Double) , (ps[0] as! NSManagedObject).value(forKey: "longitude") as! Double)

            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: origenCoor.latitude, longitude: origenCoor.longitude), span: span)
            mapa.setRegion(region, animated: true)
            
            for i in 0..<ps.count-1{
                let origenCoor = CLLocationCoordinate2DMake( CLLocationDegrees((ps[i] as! NSManagedObject).value(forKey: "latitude")as! Double) , (ps[i] as! NSManagedObject).value(forKey: "longitude") as! Double)
                let destCoor = CLLocationCoordinate2DMake( CLLocationDegrees((ps[i+1] as! NSManagedObject).value(forKey: "latitude")as! Double) , (ps[i+1] as! NSManagedObject).value(forKey: "longitude") as! Double)
                print((ps[i] as! NSManagedObject).value(forKey: "longitude")!)
                print((ps[i] as! NSManagedObject).value(forKey: "latitude")!)
                print((ps[i] as! NSManagedObject).value(forKey: "image"))
                print((ps[i] as! NSManagedObject).value(forKey: "name")!)
                origen = MKMapItem(placemark: MKPlacemark(coordinate: origenCoor))
                destino = MKMapItem(placemark: MKPlacemark(coordinate: destCoor))
                var an = CustomPointAnnotation()
                an.coordinate = origenCoor
                an.title = (ps[i] as! NSManagedObject).value(forKey: "name") as! String?
                mapa.addAnnotation(an)
                self.obtenerRuta(origen, destino: destino)
            }
            
            let destCoor = CLLocationCoordinate2DMake( CLLocationDegrees((ps[ps.count-1] as! NSManagedObject).value(forKey: "latitude")as! Double) , (ps[ps.count-1] as! NSManagedObject).value(forKey: "longitude") as! Double)
            var an = CustomPointAnnotation()
            an.coordinate = destCoor
            an.title = (ps[ps.count-1] as! NSManagedObject).value(forKey: "name") as! String?
            mapa.addAnnotation(an)

            
            /*if let label = self.detailDescriptionLabel {
             label.text = detail.timestamp!.description
             }*/
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
        }
        else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
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
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView{
            pinView = dequeuedAnnotationView
            pinView!.canShowCallout = true
            //pinView!.image=self.annotation.photo.image
        }
        else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.annotation = annotation
            pinView!.canShowCallout = true
            
            //pinView!.detailCalloutAccessoryView = UIImageView(image: self.annotation.photo.image)
            //pinView!.image=self.annotation.photo.image
            //pinView!.rightCalloutAccessoryView = self.annotation.photo
        }
        
        return pinView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.destination is PINDetailsVC{
            let dest = segue.destination as! PINDetailsVC
            dest.sourceViewController = self
            //dest.customPin = annotation
        }*/
    }
    
    func obtenerRuta(_ origen:MKMapItem, destino:MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .walking
        let indicaciones = MKDirections(request:solicitud)
        indicaciones.calculate(completionHandler: {
                (response:MKDirectionsResponse?, error:Error?) in
            
            guard let response = response else {
                return
            }
                if error != nil{
                    print(error)
                }
                else{
                    self.muestraRuta(response)
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
    
    var detailItem: Route? {
        didSet {
            // Update the view.
        }
    }
}

