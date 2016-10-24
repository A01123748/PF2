//
//  DetailViewController.swift
//  QR_Mapas
//
//  Created by Eliseo Fuentes on 10/8/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class SavedRoutesVC: UITableViewController, NSFetchedResultsControllerDelegate{

    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let origen = sender as! DetailViewController
        // Pass the selected object to the new view controller.
        if segue.identifier == "showSavedRoute" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! ShowSavedRouteVC
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let route = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withRoute: route)
        //cell.textLabel!.text = "Cell 1"
        return cell
     }
    
    func configureCell(_ cell: UITableViewCell, withRoute route: Route) {
        print("Route: "+route.name)
        cell.textLabel!.text = route.name.description
    }

    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Route> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest() as! NSFetchRequest<Route>
        
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
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Route>? = nil

}

