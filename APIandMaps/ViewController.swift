//
//  ViewController.swift
//  APIandMaps
//
//  Created by IMCS2 on 9/12/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,UISearchBarDelegate,CLLocationManagerDelegate {
    var name: String?
    var coordinateOne:Double?
    var coordinateTwo:Double?
    var searchQuery:String?
    var flag:Bool = false
    var prevName:String?
    var  prevLati: Double?
    var  prevLongi: Double?
    var prevLoc:[MKAnnotation]?
    var locationManager = CLLocationManager()
     var initFlag = true
    
    override func viewDidLoad() {
       
        
        super.viewDidLoad()
        
        searchValue.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        
        if let coor = map.userLocation.location?.coordinate{
            map.setCenter(coor, animated: true)
        }
        

    }
    
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var searchValue: UISearchBar!
    let  annotation = MKPointAnnotation()
    
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
         getCoordinates()
    }
    
    func getCoordinates() {
        
        
        
//        let  annotation = MKPointAnnotation()
        
//        if flag == true
//        {
//            let  prevCoord = CLLocationCoordinate2D(latitude: prevLati!, longitude: prevLongi!)
//            annotation.title = prevName!
//            annotation.coordinate = prevCoord
//
//            prevLoc?.append(annotation)
//
//            map.removeAnnotation(annotation)
////            map.reloadInputViews()
////            map.removeAnnotations(prevLoc!)
//
//        }
        
        searchQuery = searchValue.text
        
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
                      //  print("Array Count", resourrceTwo!.count)
                        

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
                        
                        
                        self.annotation.title = self.name
                        self.prevName = self.name
                        self.prevLati = latitude as? Double
                        self.prevLongi = longitude as? Double
                        self.annotation.coordinate = coordinates
                     //   self.flag = true
                        self.map.addAnnotation(self.annotation)
                        
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
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
       
        if initFlag {

            initFlag = false
        } else {
        
            if flag == true
            {
                let  prevCoord = CLLocationCoordinate2D(latitude: prevLati!, longitude: prevLongi!)
                annotation.title = prevName!
                annotation.coordinate = prevCoord
                
                prevLoc?.append(annotation)
                
                map.removeAnnotation(annotation)
               
                
            }
        
        
        }
    }
    
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//
//        map.mapType = MKMapType.standard
//
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        let region = MKCoordinateRegion(center: locValue, span: span)
//        map.setRegion(region, animated: true)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locValue
//        annotation.title = "Ashish Patel"
//        annotation.subtitle = "current location"
//        map.addAnnotation(annotation)
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        let latitude: CLLocationDegrees = userLocation.coordinate.latitude
        let longitude: CLLocationDegrees = userLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let longDelta: CLLocationDegrees = 0.005
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        let region = MKCoordinateRegion(center: coordinates, span: span)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = "Ashish Patel"
                annotation.subtitle = "current location"
                map.showsUserLocation = true
              //  map.addAnnotation(annotation)
        
    }
    
}

