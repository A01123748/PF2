//
//  EventsVC.swift
//  QR_Mapas
//
//  Created by Eliseo Fuentes on 10/23/16.
//  Copyright © 2016 Eliseo Fuentes. All rights reserved.
//

import UIKit

class EventsVC: UITableViewController {
    
    var events = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonString = "{\"Eventos\": [{\"Nombre\":\"Feria\", \"Fecha\":\"10062016\", \"Descripcion\":\"Feria del elote toda la semana\"},{\"Nombre\": \"Concierto\", \"Fecha\":\"11052016\", \"Descripcion\":\"Concierto dia de Muertos\"},{\"Nombre\": \"Arte\", \"Fecha\":\"01012017\", \"Descripcion\":\"Toca una obra de arte\"}]}"
        if let data = jsonString.data(using: String.Encoding.utf8){
            let err : NSErrorPointer = nil

            do{
                
                let json = try JSONSerialization.jsonObject(with: data,
                                                                options: .mutableLeaves)
                if (err != nil) {
                    print("Error: \(err)")
                }
                else {
                    let dico1 = json as! NSDictionary
                    events = dico1["Eventos"] as! NSArray
                }
            }
            catch {
                print(error)
            }
            
        }


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let dico = events[indexPath.row] as! NSDictionary
        cell.textLabel?.text = dico["Nombre"] as? String
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let dest = segue.destination as! EventDetailsVC
            print(indexPath.row)
            print(events[indexPath.row])
            let event = events[indexPath.row] as! NSDictionary
            dest.name = (event["Nombre"] as? String)!
            dest.date = (event["Fecha"] as? String)!
            dest.desc
                = (event["Descripcion"] as? String)!
        }
    }
    

}
