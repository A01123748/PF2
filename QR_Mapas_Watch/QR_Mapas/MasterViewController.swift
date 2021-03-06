//
//  MasterViewController.swift
//  QR_Mapas
//
//  Created by Eliseo Fuentes on 10/8/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        /*let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }*/
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRoute" {
            //if let indexPath = self.tableView.indexPathForSelectedRow {
            //let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! MapsVC
                //controller.detailItem = object
                controller.managedObjectContext = self.managedObjectContext
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            //}
        }
        else if segue.identifier == "showSavedRoutes" {
            //if let indexPath = self.tableView.indexPathForSelectedRow {
            //let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
            let controller = segue.destination as! SavedRoutesVC
            //controller.detailItem = object
            controller.managedObjectContext = self.managedObjectContext
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            //}
        }
    }
    
    }

