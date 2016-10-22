//
//  InterfaceController.swift
//  QR_Mapas_Watch Extension
//
//  Created by Eliseo Fuentes on 10/9/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import CoreData

open class WatchCoreDataProxy: NSObject {
    
    let sharedAppGroup:String = "group.maps.watch"
    
    open class var sharedInstance : WatchCoreDataProxy {
        struct Static {
            static let instance : WatchCoreDataProxy = WatchCoreDataProxy()
        }
        return Static.instance
    }
    
    // MARK: - Core Data stack
    
    open lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        let proxyBundle = Bundle(identifier: "group.maps.watch")
        
        let modelURL = proxyBundle?.url(forResource: "QR_Mapas", withExtension: "momd")!
        //let modelURL = NSBundle.mainBundle().URLForResource("QR_Mapas", withExtension: "momd")!

        return NSManagedObjectModel(contentsOf: modelURL!)!
        }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var sharedContainerURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.sharedAppGroup)
  
        if let sharedContainerURL = sharedContainerURL {
            let storeURL = sharedContainerURL.appendingPathComponent("SingleViewCoreData.sqlite")
            do{
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                }
                catch{
                    abort()
                }
        }
            return coordinator
        }()
    
    open lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    open func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges{
            do{
                try moc.save()
            }
            catch{
                //NSLog("Unresolved error \(error), \(error.userInfo)")
                print("Error en save en WatchCoreDataProxy")
                abort()
            }
        }
        }
    }
    
}
