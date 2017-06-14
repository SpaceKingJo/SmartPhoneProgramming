//
//  ViewController.swift
//  XMLParsingDemo
//
//  Created by kpugame on 2017. 4. 24..
//  Copyright © 2017년 Jo. All rights reserved.
//

import UIKit

class ViewController_Subway: UIViewController, XMLParserDelegate {
    
    @IBOutlet weak var endSubText: UITextField!
    @IBOutlet weak var startName: UIButton!
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var tbData: UITableView!
    var getSubCode: String?
    var getSubName: String?
    var arrivalSubName: String?
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var lineName = NSMutableString()
    var listOfSubwayName: [String] = []
    var shtTransferMsg: String = ""
    var endSubName: String = ""
    var sendStart: String = ""
    var sendEnd: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startName.setTitle(getSubName, for: UIControlState.normal)
        subName.text = getSubName! + " 막차 첫차"
        beginParsing()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginParsing()
    {
        posts = []
        sendStart = getSubName!
        getSubName = getSubName?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        parser = XMLParser(contentsOf:(((NSURL(string:"http://swopenapi.seoul.go.kr/api/subway/52534a59666a6f68383379594f534e/xml/firstLastTimetable/0/5/" + getSubName!))! as URL) as URL) as URL)!
        parser.delegate = self
        parser.parse()
        tbData!.reloadData()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "row")
        {
            elements = NSMutableDictionary()
            elements = [:]
            title1 = NSMutableString()
            title1 = ""
            date = NSMutableString()
            date = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String!)
    {
        if element.isEqual(to: "subwayNm"){
            title1.append(string)
            title1.append(" ")
        } else if element.isEqual(to: "lastcarDiv"){
            if string == "1"{
                date.append("첫차: ")
            } else if string == "2"{
                date.append("막차: ")
            }
        }
        else if element.isEqual(to: "subwayename") {
            title1.append(string)
            title1.append("행 열차")
        } else if element.isEqual(to: "weekendTranHour") {
            date.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if (elementName as NSString).isEqual(to: "row") {
            if !title1.isEqual(nil) {
                elements.setObject(title1, forKey: "title" as NSCopying)
            }
            if !date.isEqual(nil) {
                elements.setObject(date, forKey: "date" as NSCopying)
            }
            posts.add(elements)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if(cell.isEqual(NSNull)) {
            cell = Bundle.main.loadNibNamed("Cell", owner: self, options: nil)?[0] as! UITableViewCell;
        }
        cell.textLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "title") as! NSString as String
        cell.detailTextLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "date") as! NSString as String
        return cell as UITableViewCell
    }
    @IBAction func SerceButtonDown(_ sender: Any) {
        endSubText.resignFirstResponder()
    }
    @IBAction func EditinDidBeginSub(_ sender: Any) {
        endSubText.text = ""
    }
    @IBAction func viewTapped(sender : AnyObject){
        endSubText.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let indexPath = self.tableView.indexPathForSelectedRow
        endSubName = endSubText.text!
        sendEnd = endSubName
        endSubName = endSubName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        endSubName = "http://swopenapi.seoul.go.kr/api/subway/52534a59666a6f68383379594f534e/xml/shortestRoute/0/5/" + getSubName! + "/" + endSubName
        if segue.identifier == "serchSegue"{
            if let gamePickerViewController = segue.destination as?
                ViewController_Serch{
                gamePickerViewController.serchXml = endSubName
                gamePickerViewController.endSubName = sendEnd
                gamePickerViewController.startSubName = sendStart
            }
        }
    }

    
    
}



