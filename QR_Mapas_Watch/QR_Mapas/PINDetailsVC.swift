//
//  PINDetailsVC.swift
//  QR_Mapas
//
//  Created by Eliseo Fuentes on 10/9/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import UIKit
import MapKit

class PINDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var coordinates: UILabel!
    @IBOutlet weak var photo: UIImageView!
    let imagePicker = UIImagePickerController()
    var sourceViewController = MapsVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        sourceViewController = sender as! MapsVC
        print("On details for PIN")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func getCameraFromRoll(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func getImageFromCamera(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photo.contentMode = .scaleAspectFit
            photo.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func insertPin(_ sender: AnyObject) {
        if(name!.text != ""){
            sourceViewController.annotation.title = name!.text
            sourceViewController.annotation.photo = photo
            sourceViewController.cAnnos.append(sourceViewController.annotation)
            sourceViewController.mapa.addAnnotation(sourceViewController.annotation)
            var annotations = sourceViewController.mapa.annotations
            if(annotations.count > 1){
                var i = 0
                var j = 1
                var origen:MKMapItem
                var destino:MKMapItem
                for _ in 1..<sourceViewController.mapa.annotations.count{
                    origen = MKMapItem(placemark: MKPlacemark(coordinate: annotations[i].coordinate, addressDictionary: nil))
                    destino = MKMapItem(placemark: MKPlacemark(coordinate: annotations[j].coordinate, addressDictionary: nil))
                    sourceViewController.obtenerRuta(origen, destino: destino)
                    i+=1
                    j+=1
                }
            }
            _ = navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        //dismissViewControllerAnimated(true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
        //self.navigationController?.popViewControllerAnimated(true)
    }
}
