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
import CoreData

 var locationArray:[MKAnnotation] = []

class ViewController: UIViewController,MKMapViewDelegate,UISearchBarDelegate,CLLocationManagerDelegate {
    var name: String?
    var coordinateOne:Double?
    var coordinateTwo:Double?
    var searchQuery:String?
    var flag:Bool = false
    var locationManager = CLLocationManager()
    var initFlag = true
    var flagCheck:Bool = false
    var locations: [NSManagedObject] = []
    var locFetch: [NSManagedObject] = []
    var fetchedTitles: [String] = []
    var ttF :String = ""
    var lTitle = " "
    var receivedLong : Double = 0.0
    var receivedLat : Double = 0.0
    var searchLocation:MKAnnotation?
    var currentAnnotation:MKAnnotation?
    var currentAnnoName: String?
    var currentAnnoLatitude:Double?
    var currentAnnotLongitude:Double?
   
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
    
    @IBAction func mapViewSelector(_ sender: Any) {
        switch ((sender as AnyObject).selectedSegmentIndex) {
        case 0:
            map.mapType = .standard
        case 1:
            map.mapType = .satellite
        case 2:
            map.mapType = .hybrid
        default:
            map.mapType = .standard
        }
        
    }
    
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
        alert.addAction(UIAlertAction(title: "Pin", style: .default, handler: { action in
            
            if let locationName = alert.textFields?.first?.text {
                annotation.title = locationName
                annotation.coordinate = coordinates
//
//                self.coordinateOne = latit
//                self.coordinateTwo = longit
                self.name = annotation.title
       
            }
        }))
        
       
        
        
        
        self.present(alert, animated: true)
        map.addAnnotation(annotation)
    }
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
         getCoordinates()
    }
    
    func getCoordinates() {
        
     locationManager.stopUpdatingLocation()
        
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
        

        self.currentAnnotation = view.annotation!
        self.currentAnnoName = self.currentAnnotation?.title as? String
        self.currentAnnoLatitude = self.currentAnnotation?.coordinate.latitude
        self.currentAnnotLongitude = self.currentAnnotation?.coordinate.longitude
        

        let alert = UIAlertController(title: "Save Location", message: "Do you want to add this place to your list", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
    
            //self.currentAnnotation = view.annotation!
            
            self.fetch()
            let currentCoordTitle = self.currentAnnotation?.title as? String
            
            for var i in self.fetchedTitles {
                
                if (i.isEqual(currentCoordTitle)) {
                   
                    self.flagCheck = true
                    
                }
                else {
                    
                   
                }
            }
            
            if self.flagCheck == true
                
            {
                let alert = UIAlertController(title: "Location Already Exist", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
               
                
                self.flagCheck = false
            }
                
            else {
                
                
                self.save(title: self.currentAnnoName!,longitude: self.currentAnnotLongitude! , latitude: self.currentAnnoLatitude!)
             
                let alert = UIAlertController(title: "Location Saved", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)

                
            }
            
        }))
        
        
        
        

        
      
            self.present(alert, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toP",
            let destination = segue.destination as? PlaceListViewController
            {
                
             //   destination.fetch()
             
      
                
            destination.locationArrayCopy =  locationArray
            destination.locationTitlesCopy = fetchedTitles
           
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
    
    // CoreData Save
    
    func save(title: String,longitude: Double, latitude: Double) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Location",
                                       in: managedContext)!
        
        let person = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        person.setValue(title, forKeyPath: "title")
        person.setValue(longitude, forKeyPath: "longitude")
        person.setValue(latitude, forKeyPath: "latitude")
        // 4
        do {
            try managedContext.save()
            
            locations.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }

    
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
            locFetch = try managedContext.fetch(fetchRequest)
           
            
            for locValues in locFetch {
                
        //        latF = ((locValues.value(forKeyPath: "lati")) as? NSNumber)!
        //        lonF = ((locValues.value(forKeyPath: "longi")) as? NSNumber)!
                  ttF = ((locValues.value(forKeyPath: "title")) as? String)!
                
//                latTotalF.append(latF)
//                lonTotalF.append(lonF)
                fetchedTitles.append(ttF)
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (receivedLong != 0.0) && (receivedLat != 0.0){
            
            locationManager.stopUpdatingLocation()
          
            let latitude: CLLocationDegrees = receivedLat
            let longitude: CLLocationDegrees = receivedLong
            let latDelta: CLLocationDegrees = 0.05
            let longDelta: CLLocationDegrees = 0.05
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            
            let region = MKCoordinateRegion(center: coordinates, span: span)
            map.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.title = lTitle
            annotation.coordinate = coordinates
            
            map.addAnnotation(annotation)
            
        }
    }
    
}

