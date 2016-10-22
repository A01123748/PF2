//
//  InterfaceController.swift
//  QR_Mapas_Watch Extension
//
//  Created by Eliseo Fuentes on 10/9/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import CoreData

open class DataManager: NSObject {
    
    open class func getContext() -> NSManagedObjectContext {
        return WatchCoreDataProxy.sharedInstance.managedObjectContext!
    }
    
    open class func deleteManagedObject(_ object:NSManagedObject) {
        getContext().delete(object)
        saveManagedContext()
    }
    
    open class func saveManagedContext() {
        do{
            try getContext().save()
        }
        catch{
            print("Error en el save")
            abort()
        }
    }

}
