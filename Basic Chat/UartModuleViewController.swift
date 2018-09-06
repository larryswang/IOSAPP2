//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//





import UIKit
import CoreBluetooth

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    //View
    @IBOutlet weak var headView: UIImageView!
    @IBOutlet weak var bodyView: UIImageView!
    @IBOutlet weak var legView: UIImageView!
    @IBOutlet weak var feetView: UIImageView!
    @IBOutlet weak var sensorBackGround: UIImageView!
    @IBOutlet weak var imageBackGround: UIImageView!
    @IBOutlet weak var aboutView: UIImageView!
    @IBOutlet weak var motionView: UIImageView!
    
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
    
    @IBOutlet weak var hipTime: UILabel!
    @IBOutlet weak var feetTime: UILabel!
    @IBOutlet weak var shoulderTime: UILabel!
    //Data
    var startedRecord : Bool = false
    var shoulderStillTime : Int = 0
    var hipStillTime : Int = 0
    var feetStillTime : Int = 0
    var filePath : String = ""
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var shoulderStart = NSDate()
    var hipStart = Date()
    var feetStart = Date()
    
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    //Data matrix
    var sensor1data : [Float] = []
    var sensor2data : [Float] = []
    var sensor3data : [Float] = []
    var sensor4data : [Float] = []
    var sensor5data : [Float] = []
    var sensor6data : [Float] = []
    
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
        
        self.imageBackGround.layer.borderWidth = 5
        self.imageBackGround.layer.borderColor = UIColor.blue.cgColor
        self.imageBackGround.layer.cornerRadius = 5
        self.imageBackGround.layer.masksToBounds = true
        
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
            (sender as! UIButton).setTitle("RECORD", for:UIControlState.normal)
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
                (sender as! UIButton).setTitle("STOP", for:UIControlState.normal)
                let login:NSString = alertController.textFields!.first!.text! as NSString
                self.filePath="\( login).txt"
                print(self.filePath)
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
            "This APP is used for Lack of Motion prototype, for research use only. The Lack of Motion detecting system as well as algorithm is developed by Larry(Shiyu) Wang shiyuw@umich.edu, Biomechanics Research Lab, Mechanical Engineering of University of Michigan. Any individual as well as company must not copy without inquring.", preferredStyle: UIAlertControllerStyle.alert)
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
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            let appendString = "\n"
            let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
            let myAttributes2 = [NSFontAttributeName: myFont!, NSForegroundColorAttributeName: UIColor.red]
            let attribString = NSAttributedString(string: (characteristicASCIIValue as String) + appendString, attributes: myAttributes2)
            let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
            
            let aMessage = attribString.string
            
            if(aMessage.contains("#") || aMessage.contains("*")){
                
                if(aMessage.contains("#")){
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 2)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.sensor1.text = aMessage[range1]  // play
                    self.sensor1data.append((self.sensor1.text! as NSString).floatValue)
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 8)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.sensor2.text = aMessage[range2]  // play
                    self.sensor2data.append((self.sensor2.text! as NSString).floatValue)
                    
                    let start3 = aMessage.index(aMessage.startIndex, offsetBy: 14)
                    let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                    let range3 = start3..<end3
                    self.sensor3.text = aMessage[range3]  // play
                    self.sensor3data.append((self.sensor3.text! as NSString).floatValue)
                }
                
                if(aMessage.contains("*")){
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 2)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.sensor4.text = aMessage[range1]  // play
                    self.sensor4data.append((self.sensor4.text! as NSString).floatValue)
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 8)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.sensor5.text = aMessage[range2]  // play
                    self.sensor5data.append((self.sensor5.text! as NSString).floatValue)
                    
                    let start3 = aMessage.index(aMessage.startIndex, offsetBy: 14)
                    let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                    let range3 = start3..<end3
                    self.sensor6.text = aMessage[range3]  // play
                    self.sensor6data.append((self.sensor6.text! as NSString).floatValue)
                }
            }
            self.consoleAsciiText = newAsciiText
            
            // drop some data to prevent memory out of usage
            if self.sensor1data.count == 1{
                self.shoulderStart = NSDate()
                print("NSDate: " , self.shoulderStart)
                
                self.hipStart = Date()
                self.feetStart = Date()
            }
            
            if self.sensor1data.count > 20{
                self.sensor1data = Array(self.sensor1data.suffix(20));
            }
            
            if self.sensor2data.count > 20{
                self.sensor2data = Array(self.sensor2data.suffix(20));
            }
            
            if self.sensor3data.count > 20{
                self.sensor3data = Array(self.sensor3data.suffix(20));
            }
            
            if self.sensor4data.count > 20{
                self.sensor4data = Array(self.sensor4data.suffix(20));
            }
            
            if self.sensor5data.count > 20{
                self.sensor5data = Array(self.sensor5data.suffix(20));
            }
            
            if self.sensor6data.count > 20{
                self.sensor6data = Array(self.sensor6data.suffix(20));
            }
            
            if self.startedRecord {
                self.recordData()
            }
            if self.sensor1data.count != 0 && self.sensor4data.count != 0{
                self.calcStillTime()
                self.updatePictures()
                self.getMotion()
            }
        }
    }
    
    func recordData(){
        let fileManager = FileManager.default
        let filePath1:String = NSHomeDirectory() + "/Documents/\(self.filePath as String)"
        var exist = fileManager.fileExists(atPath: filePath1)
        //let pioneerString="\n"
        exist = !exist
        
        /*if exist{
            try! pioneerString.write(toFile: filePath1, atomically: true, encoding: String.Encoding.utf8)
            print(filePath1)
            
        }*/
        let now = Date()
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm:ss.SSS"
        let timeString = outputFormatter.string(from: now)
        let value1 = sensor1.text
        let value2 = sensor2.text
        let value3 = sensor3.text
        let value4 = sensor4.text
        let value5 = sensor5.text
        let value6 = sensor6.text
        let debugValue = "MVL"
        let info = "\(timeString) \(value1 ?? debugValue) \(value2 ?? debugValue) \(value3 ?? debugValue) \(value4 ?? debugValue) \(value5 ?? debugValue) \(value6 ?? debugValue)\n"
        let manager = FileManager.default
        let urlsForDocDirectory = manager.urls(for:.documentDirectory, in:.userDomainMask)
        let docPath = urlsForDocDirectory[0]
        let file = docPath.appendingPathComponent(self.filePath)
        print(file)
        
        let appendedData = info.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let fileHandle :FileHandle = FileHandle(forWritingAtPath: filePath1)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(appendedData!)
        fileHandle.closeFile()
    }
    
    func calcStillTime(){
        let curData1 = sensor1data[sensor1data.count-1]
        let curData2 = sensor2data[sensor2data.count-1]
        let curData3 = sensor3data[sensor3data.count-1]
        let curData4 = sensor4data[sensor4data.count-1]
        let curData5 = sensor5data[sensor5data.count-1]
        let curData6 = sensor6data[sensor6data.count-1]
        
        if(curData1 > 2 || curData4 > 2){
            self.shoulderStart = NSDate();
        }
        
        if(curData2 > 2 || curData5 > 2){
            self.hipStart = Date();
        }
        
        if(curData3 > 2 || curData6 > 2){
            self.feetStart = Date();
        }
        
        let difference1 = Date().timeIntervalSince(self.shoulderStart as Date)
        print("difference1: \(difference1)")
        let hours1 = Int(difference1) / 3600
        let minutes1 = (Int(difference1) / 60) % 60
        let second1 = (Int(difference1)) % 60
        self.shoulderTime.text = "\(hours1) h \(minutes1) m \(second1) s"
        self.shoulderStillTime = Int(difference1)
        
        let difference2 = Date().timeIntervalSince(self.hipStart)
        let hours2 = Int(difference2) / 3600
        let minutes2 = (Int(difference2) / 60) % 60
        let second2 = (Int(difference2)) % 60
        self.hipTime.text = "\(hours2) h \(minutes2) m \(second2) s"
        self.hipStillTime = Int(difference2)
        
        let difference3 = Date().timeIntervalSince(self.feetStart)
        let hours3 = Int(difference3) / 3600
        let minutes3 = (Int(difference3) / 60) % 60
        let second3 = (Int(difference3)) % 60
        self.feetTime.text = "\(hours3) h \(minutes3) m \(second3) s"
        self.feetStillTime = Int(difference3)
    }
    
    func updatePictures(){
        let headImageName = "greenhead.png"
        var shoulderImageName : String
        var legImageName : String
        var feetImageName : String
        if(self.shoulderStillTime > 20){
            shoulderImageName = "redbody.png"
        }
        else if(self.shoulderStillTime > 10){
            shoulderImageName = "yellowbody.png"
        }
        else{
            shoulderImageName = "greenbody.png"
        }
        if(self.hipStillTime > 20){
            legImageName = "redleg.png"
        }
        else if(self.hipStillTime > 10){
            legImageName = "yellowleg.png"
        }
        else{
            legImageName = "greenleg.png"
        }
        if(self.feetStillTime > 20){
            feetImageName = "redfeet.png"
        }
        else if(self.feetStillTime > 10){
            feetImageName = "yellowfeet.png"
        }
        else{
            feetImageName = "greenfeet.png"
        }
        self.headView.image = UIImage(named: headImageName)
        self.bodyView.image = UIImage(named: shoulderImageName)
        self.legView.image = UIImage(named: legImageName)
        self.feetView.image = UIImage(named: feetImageName)
    }
    
    func getMotion(){
        
    }
    
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

