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

class ViewController: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate {
    
    var gpsParser = XMLParser()
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var gpsElement = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var subwayID = NSMutableString()
    var lineName = NSMutableString()
    var gpsString: String = ""
    var wgsX = NSMutableString()
    var wgsY = NSMutableString()
    
    let animals = ["막차 계산하기", "Dog", "Cow", "Mulval"]
    @IBOutlet
    var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myPositionButton: UIButton!
    var locationManager:CLLocationManager!
    var timer = Timer()
    let regionRadius: CLLocationDistance = 300
    //let initialLocation = CLLocation(latitude)
    @IBAction func SetMyPosition(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        //let myPos = Artwork(title: "내 위치",
        //                    locationName: "My Position",
        //                    discipline: "Sculpture",
        //                    coordinate: locationManager.location!.coordinate)
        let jeong = Artwork(title: "지하철",
                            locationName: "정왕역",
                            discipline: "Sculpture",
                            coordinate: CLLocationCoordinate2D(latitude: 37.351746, longitude: 126.742956))
        //mapView.addAnnotation(myPos)
        mapView.addAnnotation(jeong)
        mapView.showsUserLocation = true
        centerMapOnLocation(location: locationManager.location!)
    }
    
    func beginParsing(location: CLLocation)
    {
        gpsString.append("y=")
        gpsString.append(String(format:"%f", location.coordinate.latitude))
        gpsString.append("&x=")
        gpsString.append(String(format:"%f", location.coordinate.longitude))
        gpsParser = XMLParser(contentsOf:(NSURL(string:"https://apis.daum.net/local/geo/transcoord?apikey=1862cf21a0ded458d13db39f9bc16ff6&fromCoord=WGS84&" + gpsString + "&toCoord=WTM&output=xml"))! as URL)!
        gpsParser.delegate = self
        gpsParser.parse()
        print("https://apis.daum.net/local/geo/transcoord?apikey=1862cf21a0ded458d13db39f9bc16ff6&fromCoord=WGS84&" + gpsString + "&toCoord=WTM&output=xml")
        
        posts = []
        parser = XMLParser(contentsOf:(NSURL(string:"http://swopenapi.seoul.go.kr/api/subway/52534a59666a6f68383379594f534e/xml/nearBy/0/5/" + String(format:"%f", wgsX) + "/" + String(format:"%f", wgsY)))! as URL)!
        parser.delegate = self
        parser.parse()
        tableView!.reloadData()
    }
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        gpsElement = elementName as NSString
        if (elementName as NSString).isEqual(to: "result")
        {
            print(attributeDict)
            wgsX = NSMutableString()
            wgsX = ""
            wgsY = NSMutableString()
            wgsY = ""
        }
        
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "row")
        {
            elements = NSMutableDictionary()
            elements = [:]
            subwayID = NSMutableString()
            subwayID = ""
            title1 = NSMutableString()
            title1 = ""
            date = NSMutableString()
            date = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String!)
    {
        if element.isEqual(to: "statnId"){
            subwayID.append(string)
            subwayID.append(" ")
        }
        else if element.isEqual(to: "statnNm"){
            title1.append(string)
            title1.append("역 ")
        } else if element.isEqual(to: "subwayNm"){
            date.append(string)
            date.append(" ")
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if (elementName as NSString).isEqual(to: "row") {
            if !subwayID.isEqual(nil) {
                elements.setObject(subwayID, forKey: "ID" as NSCopying)
            }
            if !title1.isEqual(nil) {
                elements.setObject(title1, forKey: "title" as NSCopying)
            }
            if !date.isEqual(nil) {
                elements.setObject(date, forKey: "date" as NSCopying)
            }
            posts.add(elements)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        //let myPos = Artwork(title: "내 위치",
        //                    locationName: "My Position",
        //                    discipline: "Sculpture",
        //                    coordinate: locationManager.location!.coordinate)
        //mapView.addAnnotation(myPos)
        //mapView.addAnnotation(myPos)
        mapView.showsUserLocation = true
        centerMapOnLocation(location: locationManager.location!)
        beginParsing(location: locationManager.location!)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.Wait1s), userInfo: nil, repeats: true)
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
        print("1초마다 한 번씩 불린다.")
        print(wgsX)
        print(wgsY)
        //centerMapOnLocation(location: locationManager.location!)
        //centerMapOnLocation(location: locationManager.location!)
        //locationManager.startUpdatingLocation()
        //print("asd")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell"/*Identifier*/, for: indexPath as //IndexPath)
        //cell.textLabel?.text = animals[indexPath.row]
        //return cell
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if(cell.isEqual(NSNull)) {
            cell = Bundle.main.loadNibNamed("Cell", owner: self, options: nil)?[0] as! UITableViewCell;
        }
        cell.textLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "title") as! NSString as String
        cell.detailTextLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "date") as! NSString as String
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

