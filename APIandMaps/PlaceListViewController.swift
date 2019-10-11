//
//  PlaceListViewController.swift
//  APIandMaps
//
//  Created by IMCS2 on 9/20/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PlaceListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var locationArrayCopy:[MKAnnotation] = []
    var thisLoc: [NSManagedObject] = []
    var latF:NSNumber = 0.0
    var lonF:NSNumber = 0.0
    var tF :String = ""
    var latTotalF: [NSNumber] = []
    var lonTotalF: [NSNumber] = []
    var ttTotal: [String] = []
    var locationTitlesCopy:[String] = []
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if thisLoc.isEmpty {

            return 1
        }
        else
        {
            return thisLoc.count
            
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        

        if thisLoc.isEmpty {

            cell.textLabel?.text = "{ Empty }"
        }

        else {
             let title = thisLoc[indexPath.row]
            
            cell.textLabel?.text = title.value(forKeyPath: "title") as? String
       }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if thisLoc.isEmpty{
            
            
        }
            
        else
        {
        
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
         //  tableView.deleteRows(at: [indexPath], with: .fade)
            
            
          
            
                delete(location: thisLoc[indexPath.row])
          
            
            }
            //   self.thisLoc.remove(at: indexPath.row)
        
            
       
            
            //tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
      fetch()

    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
     
        
        if thisLoc.isEmpty {
            
        }
        else {
        
            
            
        if segue.identifier == "toMap",
            let destination = segue.destination as? ViewController,
            let locationIndex = tableView.indexPathForSelectedRow?.row{
            
            destination.navigationItem.rightBarButtonItem = nil
            destination.view.addSubview(destination.searchValue!)
            destination.searchValue?.translatesAutoresizingMaskIntoConstraints = false
            destination.searchValue?.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
            
            destination.receivedLat =  Double(truncating: latTotalF[locationIndex])
            destination.receivedLong = Double(truncating: lonTotalF[locationIndex])
            destination.lTitle =  ttTotal[locationIndex]
           

            
            }
            
        }
    }
    
    
    @IBOutlet var tableView: UITableView!
    
    
    func fetch() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        //3
        do {
            thisLoc = try managedContext.fetch(fetchRequest)
         
            
            for locValues in thisLoc {
                
                        latF = ((locValues.value(forKeyPath: "latitude")) as? NSNumber)!
                        lonF = ((locValues.value(forKeyPath: "longitude")) as? NSNumber)!
                        tF = ((locValues.value(forKeyPath: "title")) as? String)!
                
                           latTotalF.append(latF)
                           lonTotalF.append(lonF)
                           ttTotal.append(tF)
            
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func delete(location: NSManagedObject) {
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
         
        do {
           managedContext.delete(location)
          
            try managedContext.save()
             fetch()
           tableView.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    

}
