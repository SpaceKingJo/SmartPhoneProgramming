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
    var posParser = XMLParser()
    var posParsers: [XMLParser] = []
    var codeParsers: [XMLParser] = []
    var codeParser = XMLParser()
    var posts = NSMutableArray()
    var codePosts = NSMutableArray()
    var posPosts = NSMutableArray()
    var elements = NSMutableDictionary()
    var codeElements = NSMutableDictionary()
    var posElement = NSString()
    var posElements = NSMutableDictionary()
    var element = NSString()
    var gpsElement = NSString()
    var codeElement = NSString()
    var inCode = NSMutableString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var posX: [String] = []
    var posY: [String] = []
    var posName: [String] = []
    var subwayID = NSMutableString()
    var lineName = NSMutableString()
    var gpsString: String = ""
    var wgsX : String = ""
    var wgsY : String = ""
    var codeString: [String] = []
    var subAnno: [Artwork] = []
    var sendCode: String = ""
    
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
        
        for i in 0 ..< posName.count - posName.count/2{
            subAnno.append(Artwork(title: posName[i],
                                 locationName: "지하철역",
                                   discipline: "Sculpture",
                                   coordinate: CLLocationCoordinate2D(latitude: Double(posX[i])!, longitude: Double(posY[i])!)))
        }
        
        
        for tmpAnno in subAnno{
            mapView.addAnnotation(tmpAnno)
        }
        
        mapView.showsUserLocation = true
        centerMapOnLocation(location: locationManager.location!)
        beginParsing(location: locationManager.location!)
    }
    
    func beginParsing(location: CLLocation)
    {
        gpsString.append("y=")
        gpsString.append(String(format:"%f", location.coordinate.latitude))
        gpsString.append("&x=")
        gpsString.append(String(format:"%f", location.coordinate.longitude))
        gpsParser = XMLParser(contentsOf:(NSURL(string:"https://apis.daum.net/local/geo/transcoord?apikey=1862cf21a0ded458d13db39f9bc16ff6&fromCoord=WGS84&" + gpsString + "&toCoord=WTM&output=xml"))! as URL)! // 좌표계 변환
        gpsParser.delegate = self
        gpsParser.parse()
        
        posts = []
        parser = XMLParser(contentsOf:(NSURL(string:"http://swopenapi.seoul.go.kr/api/subway/52534a59666a6f68383379594f534e/xml/nearBy/0/5/" + wgsX + "/" + wgsY))! as URL)!
        // 좌표기반 주변 지하철역
        //print(wgsX)
        //print(wgsY)
        parser.delegate = self
        parser.parse()
        tableView!.reloadData()
        //http://openapi.seoul.go.kr:8088/52534a59666a6f68383379594f534e/xml/SearchLocationOfSTNByIDService/1/5/1761/
        for asd in posts{
            var subName = (asd as AnyObject).value(forKey: "title") as! NSString as String
            //print(subName)
            //subName.remove(at: subName.index(before: subName.endIndex))
            subName = subName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            codeParser = XMLParser(contentsOf:(NSURL(string:"http://openapi.seoul.go.kr:8088/52534a59666a6f68383379594f534e/xml/SearchInfoBySubwayNameService/1/1/" + subName + "/"))! as URL)!
            // 지하철역명으로 역코드 알아내기
            codeParsers.append(codeParser)
            
        }
        for tmpParser in codeParsers{
            tmpParser.delegate = self
            tmpParser.parse()
        }
        //print(posts.count)
        //print(codePosts.count)
        for tmpString in codeString{
            //var subCode = (asd as AnyObject).value(forKey: "code2") as! NSString as String
            //print(tmpString)
            posParser = XMLParser(contentsOf:(NSURL(string:"http://openapi.seoul.go.kr:8088/52534a59666a6f68383379594f534e/xml/SearchLocationOfSTNByIDService/1/5/" + tmpString + "/"))! as URL)!
            posParsers.append(posParser)
        }
        for tmpParser in posParsers{
            tmpParser.delegate = self
            tmpParser.parse()
        }
        
    }
    
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        gpsElement = elementName as NSString
        if (elementName as NSString).isEqual(to: "result")
        {
            wgsX = attributeDict["x"]!
            wgsY = attributeDict["y"]!
        }
        
        codeElement = elementName as NSString
        element = elementName as NSString
        
        if(parser.columnNumber != 5)
        {
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
        
        
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if(parser.columnNumber != 1){
            if element.isEqual(to: "statnId"){
                //if(string.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
                subwayID.append(string)
                subwayID.append(" ")
                //}
            }
            else if element.isEqual(to: "statnNm"){
                //if(string.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
                title1.append(string)
                title1.append(" ")
                //}
            } else if element.isEqual(to: "subwayNm"){
                //if(string.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
                date.append(string)
                date.append(" ")
                //}
            } else if codeElement.isEqual(to: "STATION_CD"){
                codeString.append(string)
            } else if codeElement.isEqual(to: "STATION_NM"){
                posName.append(string)
                
            } else if codeElement.isEqual(to: "XPOINT_WGS"){
                posX.append(string)
                
            } else if codeElement.isEqual(to: "YPOINT_WGS"){
                posY.append(string)
                
            }
        }
    }
    
    // 파싱이 여러개일 경우 여기서 해결한다.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if(parser.columnNumber != 7)
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
        //if(parser.columnNumber != 7)
        //{
        //if (elementName as NSString).isEqual(to: "row") {
            //if !inCode.isEqual(nil) {
                //print(inCode)
                //codeElements.setObject(inCode, forKey: "code2" as NSCopying)
            //}
            //codePosts.add(codeElements)
        //}
        //}
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
        
        for i in 0 ..< posName.count - posName.count/2{
            subAnno.append(Artwork(title: posName[i],
                                   locationName: "지하철역",
                                   discipline: "Sculpture",
                                   coordinate: CLLocationCoordinate2D(latitude: Double(posX[i])!, longitude: Double(posY[i])!)))
        }
        
        
        for tmpAnno in subAnno{
            mapView.addAnnotation(tmpAnno)
        }

        
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
        //print("1초마다 한 번씩 불린다.")
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
        if(cell.isEqual(NSNull.self)) {
            cell = Bundle.main.loadNibNamed("Cell", owner: self, options: nil)?[0] as! UITableViewCell;
        }
        cell.textLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "title") as! NSString as String
        cell.detailTextLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "date") as! NSString as String
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        sendCode = codeString[indexPath.row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calcSegue"{
            if let gamePickerViewController = segue.destination as?
                ViewController_Subway{
                gamePickerViewController.getSubCode = sendCode
            }
        }
    }
    
}

