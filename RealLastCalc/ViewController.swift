//
//  ViewController.swift
//  RealLastCalc
//
//  Created by kpugame on 2017. 5. 10..
//  Copyright © 2017년 Jo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myPositionButton: UIButton!
    var locationManager:CLLocationManager!
    var timer = Timer()
    let regionRadius: CLLocationDistance = 300
    //let initialLocation = CLLocation(latitude)
    @IBAction func SetMyPosition(_ sender: Any) {
        mapView.removeAnnotation(mapView.annotations.first!)
        let myPos = Artwork(title: "내 위치",
                            locationName: "My Position",
                            discipline: "Sculpture",
                            coordinate: locationManager.location!.coordinate)
        mapView.addAnnotation(myPos)
        centerMapOnLocation(location: locationManager.location!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let myPos = Artwork(title: "내 위치",
                            locationName: "My Position",
                            discipline: "Sculpture",
                            coordinate: locationManager.location!.coordinate)
        mapView.addAnnotation(myPos)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.Wait1s), userInfo: nil, repeats: false)
        //print(locationManager.location?.coordinate.latitude)
        // Do any additional setup after loading the view, typically from a nib.
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.82944)
    }
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        //print("update")
        //if let coor = manager.location?.coordinate{
            //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
        //}
    }
    
    func Wait1s()
    {
        centerMapOnLocation(location: locationManager.location!)
        //centerMapOnLocation(location: locationManager.location!)
        //locationManager.startUpdatingLocation()
        //print("asd")
    }
}

