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



class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager:CLLocationManager!
    var timer = Timer()
    //let initialLocation = CLLocation(latitude)
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.Update), userInfo: nil, repeats: true)
        //print(locationManager.location?.coordinate.latitude)
        // Do any additional setup after loading the view, typically from a nib.
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.82944)
    }
    
    
    let regionRadius: CLLocationDistance = 200
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        print("update")
        if let coor = manager.location?.coordinate{
            let myPos = Artwork(title: "내 위치",
                                  locationName: "My Position",
                                  discipline: "Sculpture",
                                  coordinate: locationManager.location!.coordinate)
            mapView.addAnnotation(myPos)
            centerMapOnLocation(location: locationManager.location!)
            print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
        }
    }
    
    func Update()
    {
        //centerMapOnLocation(location: locationManager.location!)
        //locationManager.startUpdatingLocation()
        //print("asd")
    }
}

