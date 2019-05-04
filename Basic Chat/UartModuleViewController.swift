//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//

extension String {
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
    func substring(range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
}

extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(total) / Double(count)
    }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

import UIKit
import CoreBluetooth

extension Array where Element: FloatingPoint {
    
    func sum() -> Element {
        return self.reduce(0, +)
    }
    
    func avg() -> Element {
        return self.sum() / Element(self.count)
    }
    
    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }
    
}

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    
    //View

    @IBOutlet weak var sensorBackGround: UIImageView!
    @IBOutlet weak var aboutView: UIImageView!
    @IBOutlet weak var motionView: UIImageView!
    @IBOutlet weak var figureView: UIImageView!
    @IBOutlet weak var ULView: UIImageView!
    @IBOutlet weak var URView: UIImageView!
    @IBOutlet weak var MLView: UIImageView!
    @IBOutlet weak var MRView: UIImageView!
    @IBOutlet weak var BLView: UIImageView!
    @IBOutlet weak var BRView: UIImageView!
    
    //UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sensor1: UILabel!
    @IBOutlet weak var sensor2: UILabel!
    @IBOutlet weak var sensor3: UILabel!
    @IBOutlet weak var sensor4: UILabel!
    @IBOutlet weak var sensor5: UILabel!
    @IBOutlet weak var sensor6: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var histButton: UIButton!
    @IBOutlet weak var bootsSwitch: UISwitch!
    @IBOutlet weak var bedExtiAlarmSwitch: UISwitch!
    var startedRecord : Bool = false
    var bootsSwitchisOn : Bool = false

    @IBOutlet weak var ULTime: UILabel!
    @IBOutlet weak var URTime: UILabel!
    @IBOutlet weak var MLTime: UILabel!
    @IBOutlet weak var MRTime: UILabel!
    @IBOutlet weak var BLTime: UILabel!
    @IBOutlet weak var BRTime: UILabel!

    var ULStillTime : Int = 0
    var URStillTime : Int = 0
    var MLStillTime : Int = 0
    var MRStillTime : Int = 0
    var BLStillTime : Int = 0
    var BRStillTime : Int = 0
    
    var filePath : String = ""
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    
    var ULStart = Date()
    var URStart = Date()
    var MLStart = Date()
    var MRStart = Date()
    var BLStart = Date()
    var BRStart = Date()
    
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
<<<<<<< HEAD
    //raw data point
    var sensor1data : Float = 0
    var sensor2data : Float = 0
    var sensor3data : Float = 0
    var sensor4data : Float = 0
    var sensor5data : Float = 0
    var sensor6data : Float = 0
    
    //raw data matrix
    var sensor1mat : [Float] = []
    var sensor2mat : [Float] = []
    var sensor3mat : [Float] = []
    var sensor4mat : [Float] = []
    var sensor5mat : [Float] = []
    var sensor6mat : [Float] = []
=======
    
    // keep most recent 100 data
    var rawData1 : [Float] = []
    var rawData2 : [Float] = []
    var rawData3 : [Float] = []
    var rawData4 : [Float] = []
    var rawData5 : [Float] = []
    var rawData6 : [Float] = []
    
    // current data from all sensors
    var data1 : Float = 0.0
    var data2 : Float = 0.0
    var data3 : Float = 0.0
    var data4 : Float = 0.0
    var data5 : Float = 0.0
    var data6 : Float = 0.0
    
    // once reaches windowSize, update dash, clear current count, and save to file
    let WINDOWSIZE = 100
    var curWindowSize = 0
    
    // once reaches max file size, create new file and save to it
    let MAXFILESIZE = 1000
    var curFileSize = 0
    var curFileCount = 1
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
        //set appearance
        self.sensorBackGround.layer.borderWidth = 5
        self.sensorBackGround.layer.borderColor = UIColor.blue.cgColor
        self.sensorBackGround.layer.cornerRadius = 5
        self.sensorBackGround.layer.masksToBounds = true
        
        self.figureView.layer.borderWidth = 5
        self.figureView.layer.borderColor = UIColor.blue.cgColor
        self.figureView.layer.cornerRadius = 5
        self.figureView.layer.masksToBounds = true
        
        self.motionView.layer.borderWidth = 5
        self.motionView.layer.borderColor = UIColor.blue.cgColor
        self.motionView.layer.cornerRadius = 5
        self.motionView.layer.masksToBounds = true
        
        self.recordButton.layer.cornerRadius = 7
        self.recordButton.layer.masksToBounds = true
        
        self.histButton.layer.cornerRadius = 7
        self.histButton.layer.masksToBounds = true
        
        //gensture control
        self.aboutView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(UartModuleViewController.singleTap))
        self.aboutView.addGestureRecognizer(gesture)
        
        
    }
    
    @IBAction func startRecording(_ sender: Any){
        weak var weakSelf = self
        if(sender as! UIButton).isSelected{
            //stop record
            self.startedRecord = false
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            (sender as! UIButton).setTitle("RECORD", for:UIControl.State.normal)
        }else{
            let alertController = UIAlertController(title: "Create document name",
                                                    message: nil, preferredStyle: .alert)
            alertController.addTextField {
                (textField: UITextField!) -> Void in
                textField.placeholder = "document name"
                let now = Date()
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "yyyyMMdd:HH:mm:ss"
                let timeString = outputFormatter.string(from: now)
                textField.text=timeString
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
                action in
                (sender as! UIButton).setTitle("STOP", for:UIControl.State.normal)
                let login:NSString = alertController.textFields!.first!.text! as NSString
                self.filePath="\( login)"
                weakSelf?.startedRecord = true
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @objc func singleTap(){
        let alertView = UIAlertController(title: "About Msafety Lab", message:
            "This APP is used for Lack of Motion prototype, for research use only. The Lack of Motion detecting system as well as algorithm is developed by Larry(Shiyu) Wang shiyuw@umich.edu, Biomechanics Research Lab, Mechanical Engineering of University of Michigan. Any individual as well as company must not copy without inquring.", preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: "OK", style:.default, handler:{_ in
            
        })
        alertView.addAction(OKAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // peripheralManager?.stopAdvertising()
        // self.peripheralManager = nil
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    var allDataIn : Bool = false
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            let appendString = "\n"
            
            let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
<<<<<<< HEAD
            let myAttributes2 = [NSAttributedString.Key.font: myFont!, NSAttributedString.Key.foregroundColor: UIColor.red]
            let attribString = NSAttributedString(string: (characteristicASCIIValue as String) + appendString, attributes: myAttributes2)
=======
            let myAttributes2 = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): myFont!, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.red]
            let attribString = NSAttributedString(string: (characteristicASCIIValue as String) + appendString, attributes: convertToOptionalNSAttributedStringKeyDictionary(myAttributes2))
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
            let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
            
            let aMessage = attribString.string
            
            if self.bootsSwitch.isOn {
                self.bootsSwitchisOn = true;
            }
            else{
                self.bootsSwitchisOn = false;
            }
            
            if(aMessage.contains("#") || aMessage.contains("*")){
                
                if(aMessage.contains("#")){
                    self.allDataIn = false
<<<<<<< HEAD
                    self.sensor1data = Float(aMessage.substring(from: 1, to: 7)) ?? 0
                    self.sensor1mat.append(self.sensor1data)
                    
                    self.sensor2data = Float(aMessage.substring(from:7, to: 13)) ?? 0
                    self.sensor2mat.append(self.sensor2data)
                    
                    if(!self.bootsSwitchisOn){
                        self.sensor3data = Float(aMessage.substring(from:13, to: 19)) ?? 0
                        self.sensor3mat.append(self.sensor3data)
                    }
                    else {
                        self.sensor3.text = "0.000"
                        self.sensor3mat.append(self.sensor3data)
=======
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 1)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.data1 = (String(aMessage[range1]) as NSString).floatValue
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.data2 = (String(aMessage[range2]) as NSString).floatValue
                    
                    if(!self.bootsSwitchisOn){
                        let start3 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                        let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                        let range3 = start3..<end3
                        self.data3 = (String(aMessage[range3]) as NSString).floatValue
                    }
                    else {
                        self.data3 = 0.0
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
                    }
                }
                
                if(aMessage.contains("*")){
                    self.allDataIn = true
<<<<<<< HEAD
                    self.sensor4data = Float(aMessage.substring(from: 2, to: 7)) ?? 0
                    self.sensor4mat.append(self.sensor4data)
                    
                    self.sensor5data = Float(aMessage.substring(from:7, to: 13)) ?? 0
                    self.sensor5mat.append(self.sensor5data)
                    
                    if(!self.bootsSwitchisOn){
                        self.sensor6data = Float(aMessage.substring(from:13, to: 19))  ?? 0
                        self.sensor6mat.append(self.sensor6data)
                    }
                    else {
                        self.sensor6.text = "0.000"
                        self.sensor6mat.append(self.sensor6data)
=======
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 1)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.data4 = (String(aMessage[range1]) as NSString).floatValue
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.data5 = (String(aMessage[range2]) as NSString).floatValue
                
                    if(!self.bootsSwitchisOn){
                        let start3 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                        let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                        let range3 = start3..<end3
                        self.data6 = (String(aMessage[range3]) as NSString).floatValue
                    }
                    else{
                        self.data6 = 0.0
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
                    }
                }
            self.consoleAsciiText = newAsciiText
            
<<<<<<< HEAD
            if self.sensor1mat.count == 1{
                self.ULStart = Date()
                self.URStart = Date()
                self.MLStart = Date()
                self.MRStart = Date()
                self.BLStart = Date()
                self.BRStart = Date()
            }
            
            if self.startedRecord && self.allDataIn {
                self.recordData()
            }
                
            let WINDOWSIZE = 100
            if self.allDataIn && self.sensor1mat.count == WINDOWSIZE{
                self.sensor1.text = String(format: "%.3f", self.sensor1mat.average)
                self.sensor1mat.removeAll()
                
                self.sensor2.text = String(format: "%.3f", self.sensor2mat.average)
                self.sensor2mat.removeAll()
                
                self.sensor3.text = String(format: "%.3f", self.sensor3mat.average)
                self.sensor3mat.removeAll()
                
                self.sensor4.text = String(format: "%.3f", self.sensor4mat.average)
                self.sensor4mat.removeAll()
                
                self.sensor5.text = String(format: "%.3f", self.sensor5mat.average)
                self.sensor5mat.removeAll()
                
                self.sensor6.text = String(format: "%.3f", self.sensor6mat.average)
                self.sensor6mat.removeAll()
            }
=======
            if self.allDataIn{
                // append raw data into raw data array
                self.rawData1.append(self.data1)
                self.rawData2.append(self.data2)
                self.rawData3.append(self.data3)
                self.rawData4.append(self.data4)
                self.rawData5.append(self.data5)
                self.rawData6.append(self.data6)
                
                // record data if it started
                if self.startedRecord{
                    self.recordData()
                }
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
            }
        }
    }
    let MAXFILESIZE : Int = 500
    var curfilesize : Int = 0
    var curfileidx : Int = 0
    func recordData(){
        // create file manager and create file name
        let fileManager = FileManager.default
<<<<<<< HEAD
        if (self.curfilesize == self.MAXFILESIZE){
            self.curfileidx += 1
            self.curfilesize = 0
        }
        let filePath1:String = NSHomeDirectory() + "/Documents/\(self.filePath as String)-\(self.curfileidx).txt"
        let exist = fileManager.fileExists(atPath: filePath1)
        //let pioneerString="\n"
        if(exist){
            
=======
        if(self.curFileSize == self.MAXFILESIZE){
            self.curFileCount += 1
            self.curFileSize = 0
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
        }
        let filePath1:String = NSHomeDirectory() + "/Documents/\(self.filePath as String)-\(self.curFileCount)"
        let exist = fileManager.fileExists(atPath: filePath1)
        if(!exist){
            fileManager.createFile(atPath: filePath1, contents: nil, attributes: nil)
        }
<<<<<<< HEAD
        
=======

        // create string to write
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
        let now = Date()
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm:ss.SSS"
        
        let timeString = outputFormatter.string(from: now)
<<<<<<< HEAD
        let value1 = String(self.sensor1data)
        let value2 = String(self.sensor2data)
        let value3 = String(self.sensor3data)
        let value4 = String(self.sensor4data)
        let value5 = String(self.sensor5data)
        let value6 = String(self.sensor6data)
        var info = "\(timeString) \(value1 ) \(value2 ) \(value3 ) \(value4 ) \(value5 ) \(value6 )\n"
        let WINDOWSIZE = 100
        if self.sensor1mat.count == WINDOWSIZE{
            self.curfilesize += 1
            let avvalue1 = String(self.sensor1mat.average)
            let avvalue2 = String(self.sensor2mat.average)
            let avvalue3 = String(self.sensor3mat.average)
            let avvalue4 = String(self.sensor4mat.average)
            let avvalue5 = String(self.sensor5mat.average)
            let avvalue6 = String(self.sensor6mat.average)
            info = "\(info)AVE\(timeString) \(avvalue1) \(avvalue2) \(avvalue3) \(avvalue4) \(avvalue5) \(avvalue6)\n"
        }
=======
        let value1 = String(describing: self.data1)
        let value2 = String(describing: self.data2)
        let value3 = String(describing: self.data3)
        let value4 = String(describing: self.data4)
        let value5 = String(describing: self.data5)
        let value6 = String(describing: self.data6)
        var info = "\(timeString) \(value1 ) \(value2 ) \(value3 ) \(value4 ) \(value5 ) \(value6 )\n"
        self.curFileSize += 1
        
        // append average info if necessary
        if self.curWindowSize == self.WINDOWSIZE{
            print("reaches max window size!")
            self.sensor1.text = "\(self.rawData1.avg())"
            self.sensor2.text = "\(self.rawData2.avg())"
            self.sensor3.text = "\(self.rawData3.avg())"
            self.sensor4.text = "\(self.rawData4.avg())"
            self.sensor5.text = "\(self.rawData5.avg())"
            self.sensor6.text = "\(self.rawData6.avg())"
            self.rawData1.removeAll()
            self.rawData2.removeAll()
            self.rawData3.removeAll()
            self.rawData4.removeAll()
            self.rawData5.removeAll()
            self.rawData6.removeAll()
            self.curWindowSize = 0
            // append average info into string
            info = "\(info)AVE\(timeString) \(self.sensor1.text) \(self.sensor2.text) \(self.sensor3.text) + \(self.sensor4.text) \(self.sensor5.text) \(self.sensor6.text)"
        }
        else{
            self.curWindowSize += 1
        }
        
//        let urlsForDocDirectory = fileManager.urls(for:.documentDirectory, in:.userDomainMask)
//        let docPath = urlsForDocDirectory[0]
//        let file = docPath.appendingPathComponent(self.filePath)
//        print(file)
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
        
        let appendedData = info.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let fileHandle :FileHandle = FileHandle(forWritingAtPath: filePath1)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(appendedData!)
        fileHandle.closeFile()
    }
    
//    func calcStillTime(){
<<<<<<< HEAD
//        let curData1 = sensor1data[sensor1data.count-1]
//        let curData2 = sensor2data[sensor2data.count-1]
//        let curData3 = sensor3data[sensor3data.count-1]
//        let curData4 = sensor4data[sensor4data.count-1]
//        let curData5 = sensor5data[sensor5data.count-1]
//        let curData6 = sensor6data[sensor6data.count-1]
//
//        if(curData1 > 2){
//            self.ULStart = Date();
//        }
//
//        if(curData2 > 2){
//            self.MLStart = Date();
//        }
//
//        if(curData3 > 2){
//            self.BLStart = Date();
//        }
//
//        if(curData4 > 2){
//            self.URStart = Date();
//        }
//
//        if(curData5 > 2){
//            self.MRStart = Date();
//        }
//
//        if(curData6 > 2){
//            self.BRStart = Date();
//        }
//
=======
//        let diff1 = self.data1 - self.rawData1.avg()
//        let diff2 = self.data2 - self.rawData2.avg()
//        let diff3 = self.data3 - self.rawData3.avg()
//        let diff4 = self.data4 - self.rawData4.avg()
//        let diff5 = self.data5 - self.rawData5.avg()
//        let diff6 = self.data6 - self.rawData6.avg()
//
//        if(diff1 > 3 * self.sensor1sigma){
//            self.ULStart = Date();
//        }
//
//        if(diff2 >  3 * self.sensor2sigma){
//            self.MLStart = Date();
//        }
//
//        if(diff3 >  3 * self.sensor3sigma){
//            self.BLStart = Date();
//        }
//
//        if(diff4 >  3 * self.sensor4sigma){
//            self.URStart = Date();
//        }
//
//        if(diff5 >  3 * self.sensor5sigma){
//            self.MRStart = Date();
//        }
//
//        if(diff6 >  3 * self.sensor6sigma){
//            self.BRStart = Date();
//        }
//
////        if(diff1 < -15 * self.sensor1sigma || diff2 < -15 * self.sensor2sigma || diff3 < -15 * self.sensor3sigma || diff4 < -15 * self.sensor4sigma || diff5 < -15 * self.sensor5sigma || diff6 < -15 * self.sensor6sigma || curData1 < -9 || curData2 < -9 || curData3 < -9 || curData4 < -9 || curData5 < -9 || curData6 < -9){
////
////            let alert = UIAlertController(title: "Caution", message: "BED EGRESS ALERT!", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
////                switch action.style{
////                case .default:
////                    print("default")
////
////                case .cancel:
////                    print("cancel")
////                    self.alertShowing = false
////
////                case .destructive:
////                    print("destructive")
////
////
////                }}))
////            self.present(alert, animated: true, completion: nil)
////
////            // change to desired number of seconds (in this case 5 seconds)
////            let when = DispatchTime.now() + 5
////            DispatchQueue.main.asyncAfter(deadline: when){
////                // your code with delay
////                alert.dismiss(animated: true, completion: nil)
////            }
////        }
//
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
//        let difference1 = Date().timeIntervalSince(self.ULStart)
//        let hours1 = Int(difference1) / 3600
//        let minutes1 = (Int(difference1) / 60) % 60
//        let second1 = (Int(difference1)) % 60
//        self.ULTime.text = "\(hours1) h \(minutes1) m \(second1) s"
//        self.ULStillTime = Int(difference1)
//
//        let difference2 = Date().timeIntervalSince(self.MLStart)
//        let hours2 = Int(difference2) / 3600
//        let minutes2 = (Int(difference2) / 60) % 60
//        let second2 = (Int(difference2)) % 60
//        self.MLTime.text = "\(hours2) h \(minutes2) m \(second2) s"
//        self.MLStillTime = Int(difference2)
//        if(!self.bootsSwitchisOn){
//        let difference3 = Date().timeIntervalSince(self.BLStart)
//        let hours3 = Int(difference3) / 3600
//        let minutes3 = (Int(difference3) / 60) % 60
//        let second3 = (Int(difference3)) % 60
//        self.BLTime.text = "\(hours3) h \(minutes3) m \(second3) s"
//        self.BLStillTime = Int(difference3)
//        }
//        else{
//            self.BLTime.text = "N/A"
//            self.BLStart = Date()
//        }
//        let difference4 = Date().timeIntervalSince(self.URStart)
//        let hours4 = Int(difference4) / 3600
//        let minutes4 = (Int(difference4) / 60) % 60
//        let second4 = (Int(difference4)) % 60
//        self.URTime.text = "\(hours4) h \(minutes4) m \(second4) s"
//        self.URStillTime = Int(difference4)
//        let difference5 = Date().timeIntervalSince(self.MRStart)
//        let hours5 = Int(difference5) / 3600
//        let minutes5 = (Int(difference5) / 60) % 60
//        let second5 = (Int(difference5)) % 60
//        self.MRTime.text = "\(hours5) h \(minutes5) m \(second5) s"
//        self.MRStillTime = Int(difference5)
//
//        if(!self.bootsSwitchisOn){
//        let difference6 = Date().timeIntervalSince(self.BRStart)
//        let hours6 = Int(difference6) / 3600
//        let minutes6 = (Int(difference6) / 60) % 60
//        let second6 = (Int(difference6)) % 60
//        self.BRTime.text = "\(hours6) h \(minutes6) m \(second6) s"
//        self.BRStillTime = Int(difference6)
//        }
//        else{
//            self.BRTime.text = "N/A"
//            self.BRStart = Date()
//        }
//    }
<<<<<<< HEAD
    
    func updatePictures(){
        // top left image view
        if(self.ULStillTime > 40){
            self.ULView.image = UIImage(named: "ulred.png")
        }
        else if(self.ULStillTime > 20){
            self.ULView.image = UIImage(named: "ulyel.png")
        }
        else{
            self.ULView.image = UIImage()
        }
        // top right image view
        if(self.URStillTime > 40){
            self.URView.image = UIImage(named: "urred.png")
        }
        else if(self.URStillTime > 20){
            self.URView.image = UIImage(named: "uryel.png")
        }
        else{
            self.URView.image = UIImage()
        }
        // mid left image view
        if(self.MLStillTime > 40){
            self.MLView.image = UIImage(named: "mlred.png")
        }
        else if(self.MLStillTime > 20){
            self.MLView.image = UIImage(named: "mlyel.png")
        }
        else{
            self.MLView.image = UIImage()
        }
        // mid right image view
        if(self.MRStillTime > 40){
            self.MRView.image = UIImage(named: "mrred.png")
        }
        else if(self.MRStillTime > 20){
            self.MRView.image = UIImage(named: "mryel.png")
        }
        else{
            self.MRView.image = UIImage()
        }
        // bot left image view
        if(!self.bootsSwitchisOn){
            if(self.BLStillTime > 40){
                self.BLView.image = UIImage(named: "blred.png")
            }
            else if(self.BLStillTime > 20){
                self.BLView.image = UIImage(named: "blyel.png")
            }
            else{
                self.BLView.image = UIImage()
            }
            // bot right image view
            if(self.BRStillTime > 40){
                self.BRView.image = UIImage(named: "brred.png")
            }
            else if(self.BRStillTime > 20){
                self.BRView.image = UIImage(named: "bryel.png")
            }
            else{
                self.BRView.image = UIImage()
            }
        }else{
            self.BLView.image = UIImage(named: "bootsleft.png")
            self.BRView.image = UIImage(named: "bootsright.png")
        }
    }
=======
>>>>>>> 7f5c04f739f03931f17528c790cedfe2ab2d2f2d
    
//    func updatePictures(){
//        // top left image view
//        if(self.ULStillTime > 40){
//            self.ULView.image = UIImage(named: "ulred.png")
//        }
//        else if(self.ULStillTime > 20){
//            self.ULView.image = UIImage(named: "ulyel.png")
//        }
//        else{
//            self.ULView.image = UIImage()
//        }
//        // top right image view
//        if(self.URStillTime > 40){
//            self.URView.image = UIImage(named: "urred.png")
//        }
//        else if(self.URStillTime > 20){
//            self.URView.image = UIImage(named: "uryel.png")
//        }
//        else{
//            self.URView.image = UIImage()
//        }
//        // mid left image view
//        if(self.MLStillTime > 40){
//            self.MLView.image = UIImage(named: "mlred.png")
//        }
//        else if(self.MLStillTime > 20){
//            self.MLView.image = UIImage(named: "mlyel.png")
//        }
//        else{
//            self.MLView.image = UIImage()
//        }
//        // mid right image view
//        if(self.MRStillTime > 40){
//            self.MRView.image = UIImage(named: "mrred.png")
//        }
//        else if(self.MRStillTime > 20){
//            self.MRView.image = UIImage(named: "mryel.png")
//        }
//        else{
//            self.MRView.image = UIImage()
//        }
//        // bot left image view
//        if(!self.bootsSwitchisOn){
//            if(self.BLStillTime > 40){
//                self.BLView.image = UIImage(named: "blred.png")
//            }
//            else if(self.BLStillTime > 20){
//                self.BLView.image = UIImage(named: "blyel.png")
//            }
//            else{
//                self.BLView.image = UIImage()
//            }
//            // bot right image view
//            if(self.BRStillTime > 40){
//                self.BRView.image = UIImage(named: "brred.png")
//            }
//            else if(self.BRStillTime > 20){
//                self.BRView.image = UIImage(named: "bryel.png")
//            }
//            else{
//                self.BRView.image = UIImage()
//            }
//        }else{
//            self.BLView.image = UIImage(named: "bootsleft.png")
//            self.BRView.image = UIImage(named: "bootsright.png")
//        }
//    }
    
    // Write functions
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    
    //MARK: UITextViewDelegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:250), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    //This on/off switch sends a value of 1 and 0 to the Arduino
    //This can be used as a switch or any thing you'd like
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
