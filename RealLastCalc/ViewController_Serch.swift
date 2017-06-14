//
//  ViewController.swift
//  XMLParsingDemo
//
//  Created by kpugame on 2017. 4. 24..
//  Copyright © 2017년 Jo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController_Serch: UIViewController, XMLParserDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var selectDay: UIPickerView!
    @IBOutlet weak var startname: UILabel!
    @IBOutlet weak var announce: UILabel!
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var tbData: UITableView!
    @IBOutlet weak var TextField: UITextView!
    var pickerDataSource = ["평일", "토요일", "일요일/휴일"];
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var serchXml: String = ""
    var tmpString: String = ""
    var tmpString2: String = ""
    var subWayNames: [String] = []
    var startSubName: String = ""
    var endSubName: String = ""
    var getId: String = ""
    var getIds: [String] = []
    var getupdowns: [String] = []
    var dayday: String = ""
    var lastparser = XMLParser()
    var lastName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayday = "평일"
        selectDay.dataSource = self;
        selectDay.delegate = self;
        beginParsing()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int{ return pickerDataSource.count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // selected value in Uipickerview in Swift
        dayday = pickerDataSource[row]
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginParsing()
    {
        posts = []
        parser = XMLParser(contentsOf:(NSURL(string:serchXml))! as URL)!
        parser.delegate = self
        parser.parse()
        tmpString = tmpString.replacingOccurrences(of: " ", with: "")
        subWayNames = tmpString.components(separatedBy: ",")
        subWayNames.remove(at: subWayNames.endIndex - 1)
        getIds = getId.components(separatedBy: ",")
        getIds.remove(at: getIds.endIndex - 1)
        announce.text = tmpString2
        startname.text = startSubName
        subName.text = endSubName
        getupdowns = []
        var oldId = getIds[0]
        var updown: String = ""
        var i: Int = 0
        for tmpId in getIds{
                if(updown != ""){
                if(abs(Int(oldId)! - Int(tmpId)!) > 100){
                    print("환승 데스네..")
                    getupdowns.append(updown)
                    updown = ""
                    oldId = tmpId
                    print(subWayNames[i])
                }
                else{
                        oldId = tmpId
                        getupdowns.append(updown)
                    }
            }
            else if(oldId == tmpId){
                
            } else if (oldId > tmpId){ // 번호가 줄어들음
                oldId = tmpId
                updown = "up"
                getupdowns.append(updown)
                print("상행")
            } else if (oldId < tmpId){ // 번호가 늘어남
                oldId = tmpId
                updown = "down"
                getupdowns.append(updown)
                print("하행")
            }
            i += 1
        }
        getupdowns.append(updown)
        tbData!.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "row")
        {
            elements = NSMutableDictionary()
            elements = [:]
            date = NSMutableString()
            date = ""
            tmpString = ""
            tmpString2 = ""
            getId = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String!)
    {
        if element.isEqual(to: "shtStatnNm") {
                tmpString.append(string)
        } else if element.isEqual(to: "shtTransferMsg") {
                tmpString2.append(string)
        } else if element.isEqual(to: "shtStatnId"){
            getId.append(string)
        } else if element.isEqual(to: "subwayNm"){
            title1.append(string)
            title1.append(" ")
        } else if element.isEqual(to: "lastcarDiv"){
            if string == "1"{
                title1.append("첫차: ")
            } else if string == "2"{
                title1.append("막차: ")
            }
        }
        else if element.isEqual(to: "subwayename") {
            title1.append(string)
            title1.append("행 열차 ")
        } else if (element.isEqual(to: "weekendTranHour") && dayday == "평일"){
            title1.append(string)
            title1.append("\r\n")
        } else if (element.isEqual(to: "saturdayTranHour") && dayday == "토요일"){
            title1.append(string)
            title1.append("\r\n")
        } else if (element.isEqual(to: "holidayTranHour") && dayday == "일요일/휴일"){
            title1.append(string)
            title1.append("\r\n")
        }

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if (elementName as NSString).isEqual(to: "row") {
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return subWayNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if(cell.isEqual(NSNull)) {
            cell = Bundle.main.loadNibNamed("Cell", owner: self, options: nil)?[0] as! UITableViewCell;
        }
        cell.textLabel?.text = subWayNames[indexPath.row]
        if(getupdowns[indexPath.row] == "up"){
            cell.detailTextLabel?.text = "상행선"
        }else{
            cell.detailTextLabel?.text = "하행선"
        }
        
        tmpString = ""
        return cell as UITableViewCell
    }
    
    @IBAction func UpdateButtonDown(_ sender: Any) {
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let tmpName = subWayNames[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        lastparser = XMLParser(contentsOf:(((NSURL(string:"http://swopenapi.seoul.go.kr/api/subway/52534a59666a6f68383379594f534e/xml/firstLastTimetable/0/5/" + tmpName))! as URL) as URL) as URL)!
        lastparser.delegate = self
        lastparser.parse()
        TextField.text = (title1 as String)
        title1 = NSMutableString()
        title1 = ""
        
    }
    @IBAction func OpenNaver(_ sender: Any) {
        let viewController = LocationMapViewController()
        viewController.title = "내위치"
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
}



