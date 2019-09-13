//
//  ViewController.swift
//  APIandMaps
//
//  Created by IMCS2 on 9/12/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate,UISearchBarDelegate {
    var name: String?
    var coordinateOne:Double?
    var coordinateTwo:Double?
    var searchQuery:String?
    
    override func viewDidLoad() {
       
        
        super.viewDidLoad()
        
        searchValue.delegate = self
        

    }
    
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var searchValue: UISearchBar!
    
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        getCoordinates()
    }
    
    func getCoordinates() {
        
        
        searchQuery = searchValue.text
        print("Yaar",searchQuery)
        
        if (((searchQuery!.contains("‘")))) || (((searchQuery!.contains("%")))) || (((searchQuery!.contains("^")))) || (((searchQuery!.contains(">")))) || (((searchQuery!.contains("<")))) || (((searchQuery!.contains("`"))))
        {
           
            
            DispatchQueue.main.async {
                
                let alert = UIAlertController(title: "Invalid Character", message: "Please Enter another a Valid location", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK :)", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
            
            
            
        }
        
 
        else {
            
        let finalSearch = searchQuery!.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: "https://dev.virtualearth.net/REST/v1/Locations/" + finalSearch + "?&key=Armn24dqt-VYsDPYZIv8j9dNtpiUBn6lxweXtQDobJXzhhVG50sAVJGUKRnpL43n")
        
        let task = URLSession.shared.dataTask(with: url!){ (Data, response, error) in
            
            if error == nil {
                if let unWrappedData = Data {
                    
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: unWrappedData,
                                                                          options: JSONSerialization.ReadingOptions.mutableContainers) as?
                        NSDictionary

                        let resourceSets = jsonResult?["resourceSets"] as? NSArray
                        let resources = resourceSets?[0] as? NSDictionary
                        let resourrceTwo = resources?["resources"] as? NSArray
                        print("Array Count", resourrceTwo!.count)
                        

                        if  resourrceTwo!.count == 0 {
                            
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: "Location Not Found", message: "Please Enter another location", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK :)", style: .cancel, handler: nil))
                                self.present(alert, animated: true)
                            }
                            
                        }
                        
                        else {
                            
                        let resoursceThree = resourrceTwo?[0] as? NSDictionary
                        self.name = resoursceThree?["name"] as? String             // gets name
                        let points = resoursceThree?["point"] as? NSDictionary
                        let getCoordinates = points?["coordinates"] as? NSArray
                        self.coordinateOne = getCoordinates?[0]  as? Double        // Latitude
                        self.coordinateTwo = getCoordinates?[1] as? Double         // Longitude
                     
                        
                        let latitude: CLLocationDegrees = self.coordinateOne!
                        let longitude: CLLocationDegrees = self.coordinateTwo!
                        let latDelta: CLLocationDegrees = 0.05
                        let longDelta: CLLocationDegrees = 0.005
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                        
                        let region = MKCoordinateRegion(center: coordinates, span: span)
                        self.map.setRegion(region, animated: true)
                        
                        let annotation = MKPointAnnotation()
                        annotation.title = self.name
                        annotation.coordinate = coordinates
                        
                        self.map.addAnnotation(annotation)
                        
                        }
                        
                }
            
                    catch {
                        print ("Error in fetcing Data")
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: "Location Not Found", message: "Please Enter another location", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK :)", style: .cancel, handler: nil))
                            
                            self.present(alert, animated: true)
                        }
                        
                        
                    }
                }
            }

        }
        
        task.resume()
        
    }
}
    
}

