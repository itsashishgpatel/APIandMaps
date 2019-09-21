//
//  PlaceListViewController.swift
//  APIandMaps
//
//  Created by IMCS2 on 9/20/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import MapKit

class PlaceListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var locationArrayCopy:[MKAnnotation] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if locationArrayCopy.isEmpty {
            
            return 1
        }
        else
        {
            return locationArrayCopy.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        if locationArrayCopy.isEmpty {
            
            cell.textLabel?.text = "{ Empty }"
        }
        
        else {
        
        cell.textLabel?.text = locationArrayCopy[indexPath.row].title as! String
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

       tableView.reloadData()
    }
    
    
    @IBOutlet var tableView: UITableView!
    

}
