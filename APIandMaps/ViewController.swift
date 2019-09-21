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
    var prevLati: Double?
    var prevLongi: Double?
    var prevLoc:[MKAnnotation]?
    var locationManager = CLLocationManager()
    var initFlag = true
    var locationArray:[MKAnnotation] = []
    var searchLocation:MKAnnotation?
    

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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(gestureRecognizer:)))
        
        uiLongPress.minimumPressDuration = 2.0
        map.addGestureRecognizer(uiLongPress)
        

    }
    
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var searchValue: UISearchBar!
    let  annotation = MKPointAnnotation()
    
    
    
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer)
    {
        let touchPoint = gestureRecognizer.location(in: self.map)
        let coordinates = map.convert(touchPoint, toCoordinateFrom: self.map)
        let annotation = MKPointAnnotation()
        
        let longit =  Double(coordinates.longitude)
        let latit = Double (coordinates.latitude)
        
        
        let alert = UIAlertController(title: "Name of the Pin Location", message: "Please Enter the Name of the location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "Input your location name here..."})
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            
            if let locationName = alert.textFields?.first?.text {
                annotation.title = locationName
                annotation.coordinate = coordinates
                
               self.locationArray.append(annotation)
                
                print("added via Txt",self.locationArray)
                
                
            //    self.save(title: locationName,longi: longit, lati: latit)
                
            }
        }))
        
        
        self.present(alert, animated: true)
        map.addAnnotation(annotation)
    }
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
         getCoordinates()
    }
    
    func getCoordinates() {
        
        
        
        
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
                        self.searchLocation = self.annotation
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("I Was Here")
        
        let alert = UIAlertController(title: "Save Location", message: "Do you want to add this place to your list", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            if let location = self.searchLocation
            
            {
                self.locationArray.append(location)
            }
            
            
            
            let alert = UIAlertController(title: "Location Saved", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            print("added",self.locationArray)
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPlaces",
            let destination = segue.destination as? PlaceListViewController
            {
            
            destination.locationArrayCopy =  locationArray
                print("to Places")
            
        }
    }
    
    
    
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

