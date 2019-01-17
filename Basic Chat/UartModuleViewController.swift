//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//





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
    

    @IBOutlet weak var ULTime: UILabel!
    @IBOutlet weak var URTime: UILabel!
    @IBOutlet weak var MLTime: UILabel!
    @IBOutlet weak var MRTime: UILabel!
    @IBOutlet weak var BLTime: UILabel!
    @IBOutlet weak var BRTime: UILabel!
    //Data
    var startedRecord : Bool = false
    var bootsSwitchisOn : Bool = false
    var ULStillTime : Int = 0
    var URStillTime : Int = 0
    var MLStillTime : Int = 0
    var MRStillTime : Int = 0
    var BLStillTime : Int = 0
    var BRStillTime : Int = 0
    
    var filePath : String = ""
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var alertShowing : Bool = false
    
    var ULStart = Date()
    var URStart = Date()
    var MLStart = Date()
    var MRStart = Date()
    var BLStart = Date()
    var BRStart = Date()
    
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    //Data matrix
    var sensor1data : [Float] = []
    var sensor2data : [Float] = []
    var sensor3data : [Float] = []
    var sensor4data : [Float] = []
    var sensor5data : [Float] = []
    var sensor6data : [Float] = []
    
    var sensor1ave : Float = 0
    var sensor2ave : Float = 0
    var sensor3ave : Float = 0
    var sensor4ave : Float = 0
    var sensor5ave : Float = 0
    var sensor6ave : Float = 0
    
    var sensor1sigma : Float = 0
    var sensor2sigma : Float = 0
    var sensor3sigma : Float = 0
    var sensor4sigma : Float = 0
    var sensor5sigma : Float = 0
    var sensor6sigma : Float = 0
    
    
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
    
    var calibrationFlag : Bool = false
    func calibrate(){
        self.sensor1sigma = self.sensor1data.std()
        self.sensor2sigma = self.sensor2data.std()
        self.sensor3sigma = self.sensor3data.std()
        self.sensor4sigma = self.sensor4data.std()
        self.sensor5sigma = self.sensor5data.std()
        self.sensor6sigma = self.sensor6data.std()
//        print("standard deviation for all sensors")
//        print(self.sensor1sigma)
//        print(self.sensor2sigma)
//        print(self.sensor3sigma)
//        print(self.sensor4sigma)
//        print(self.sensor5sigma)
//        print(self.sensor6sigma)
        self.calibrationFlag = true
    }
    
    var allDataIn : Bool = false
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            let appendString = "\n"
            
            let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
            let myAttributes2 = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): myFont!, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.red]
            let attribString = NSAttributedString(string: (characteristicASCIIValue as String) + appendString, attributes: convertToOptionalNSAttributedStringKeyDictionary(myAttributes2))
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
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 1)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.sensor1.text = String(aMessage[range1])  // play
                    self.sensor1data.append((self.sensor1.text! as NSString).floatValue)
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.sensor2.text = String(aMessage[range2])  // play
                    self.sensor2data.append((self.sensor2.text! as NSString).floatValue)
                    
                    if(!self.bootsSwitchisOn){
                        let start3 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                        let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                        let range3 = start3..<end3
                        self.sensor3.text = String(aMessage[range3])  // play
                    }
                    else {
                        self.sensor3.text = "0.000"
                    }
                    self.sensor3data.append((self.sensor3.text! as NSString).floatValue)
                }
                
                if(aMessage.contains("*")){
                    self.allDataIn = true
                    let start1 = aMessage.index(aMessage.startIndex, offsetBy: 1)
                    let end1 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let range1 = start1..<end1
                    self.sensor4.text = String(aMessage[range1])  // play
                    self.sensor4data.append((self.sensor4.text! as NSString).floatValue)
                    
                    let start2 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                    let end2 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                    let range2 = start2..<end2
                    self.sensor5.text = String(aMessage[range2])  // play
                    self.sensor5data.append((self.sensor5.text! as NSString).floatValue)
                    
                    if(!self.bootsSwitchisOn){
                        let start3 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                        let end3 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                        let range3 = start3..<end3
                        self.sensor6.text = String(aMessage[range3])  // play
                    }
                    else{
                        self.sensor6.text = "0.000"
                    }
                    self.sensor6data.append((self.sensor6.text! as NSString).floatValue)
                }
            }
            self.consoleAsciiText = newAsciiText
            
            if self.sensor1data.count < 10{
                // the alert view
                let alert = UIAlertController(title: "Calibrating", message: "The calibration lasts for around 10 seconds, please do not touch the bed during this period", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
                // change to desired number of seconds (in this case 10 seconds)
                let when = DispatchTime.now() + 10
                DispatchQueue.main.asyncAfter(deadline: when){
                    // your code with delay
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            else{
            
                // drop some data to prevent memory out of usage
                if self.sensor1data.count == 10 && self.calibrationFlag == false {
                    self.ULStart = Date()
                    self.URStart = Date()
                    self.MLStart = Date()
                    self.MRStart = Date()
                    self.BLStart = Date()
                    self.BRStart = Date()
                    self.calibrate()
                }
                
                let aveK : Int = 10
                
                if self.sensor1data.count > aveK{
                    self.sensor1data = Array(self.sensor1data.suffix(aveK))
                    self.sensor1ave = self.sensor1data.avg()
                }
                
                if self.sensor2data.count > aveK{
                    self.sensor2data = Array(self.sensor2data.suffix(aveK))
                    self.sensor2ave = self.sensor2data.avg()
                }
                
                if self.sensor3data.count > aveK{
                    self.sensor3data = Array(self.sensor3data.suffix(aveK))
                    self.sensor3ave = self.sensor3data.avg()
                }
                
                if self.sensor4data.count > aveK{
                    self.sensor4data = Array(self.sensor4data.suffix(aveK))
                    self.sensor4ave = self.sensor4data.avg()
                }
                
                if self.sensor5data.count > aveK{
                    self.sensor5data = Array(self.sensor5data.suffix(aveK))
                    self.sensor5ave = self.sensor5data.avg()
                }
                
                if self.sensor6data.count > aveK{
                    self.sensor6data = Array(self.sensor6data.suffix(aveK))
                    self.sensor6ave = self.sensor6data.avg()
                }
                
                if self.startedRecord && self.allDataIn {
                    self.recordData()
                }
                if self.sensor1data.count != 0 && self.sensor4data.count != 0{
                    self.calcStillTime()
                    self.updatePictures()
                    self.getMotion()
                }
            }
        }
    }
    
    func recordData(){
        let fileManager = FileManager.default
        let filePath1:String = NSHomeDirectory() + "/Documents/\(self.filePath as String)"
        let exist = fileManager.fileExists(atPath: filePath1)
        //let pioneerString="\n"
        if(exist){
            
        }
        else{
            fileManager.createFile(atPath: filePath1, contents: nil, attributes: nil)
        }
        
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
        let curData1 = self.sensor1data[sensor1data.count-1]
        let curData2 = self.sensor2data[sensor2data.count-1]
        let curData3 = self.sensor3data[sensor3data.count-1]
        let curData4 = self.sensor4data[sensor4data.count-1]
        let curData5 = self.sensor5data[sensor5data.count-1]
        let curData6 = self.sensor6data[sensor6data.count-1]
        
        let diff1 = curData1 - self.sensor1ave
        let diff2 = curData2 - self.sensor2ave
        let diff3 = curData3 - self.sensor3ave
        let diff4 = curData4 - self.sensor4ave
        let diff5 = curData5 - self.sensor5ave
        let diff6 = curData6 - self.sensor6ave
        
        if(diff1 > 3 * self.sensor1sigma){
            self.ULStart = Date();
        }
        
        if(diff2 >  3 * self.sensor2sigma){
            self.MLStart = Date();
        }
        
        if(diff3 >  3 * self.sensor3sigma){
            self.BLStart = Date();
        }
        
        if(diff4 >  3 * self.sensor4sigma){
            self.URStart = Date();
        }
        
        if(diff5 >  3 * self.sensor5sigma){
            self.MRStart = Date();
        }
        
        if(diff6 >  3 * self.sensor6sigma){
            self.BRStart = Date();
        }
        
        if(diff1 < -15 * self.sensor1sigma || diff2 < -15 * self.sensor2sigma || diff3 < -15 * self.sensor3sigma || diff4 < -15 * self.sensor4sigma || diff5 < -15 * self.sensor5sigma || diff6 < -15 * self.sensor6sigma || curData1 < -9 || curData2 < -9 || curData3 < -9 || curData4 < -9 || curData5 < -9 || curData6 < -9){
            
            let alert = UIAlertController(title: "Caution", message: "BED EGRESS ALERT!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    self.alertShowing = false
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
        let difference1 = Date().timeIntervalSince(self.ULStart)
        let hours1 = Int(difference1) / 3600
        let minutes1 = (Int(difference1) / 60) % 60
        let second1 = (Int(difference1)) % 60
        self.ULTime.text = "\(hours1) h \(minutes1) m \(second1) s"
        self.ULStillTime = Int(difference1)
        
        let difference2 = Date().timeIntervalSince(self.MLStart)
        let hours2 = Int(difference2) / 3600
        let minutes2 = (Int(difference2) / 60) % 60
        let second2 = (Int(difference2)) % 60
        self.MLTime.text = "\(hours2) h \(minutes2) m \(second2) s"
        self.MLStillTime = Int(difference2)
        if(!self.bootsSwitchisOn){
        let difference3 = Date().timeIntervalSince(self.BLStart)
        let hours3 = Int(difference3) / 3600
        let minutes3 = (Int(difference3) / 60) % 60
        let second3 = (Int(difference3)) % 60
        self.BLTime.text = "\(hours3) h \(minutes3) m \(second3) s"
        self.BLStillTime = Int(difference3)
        }
        else{
            self.BLTime.text = "N/A"
            self.BLStart = Date()
        }
        let difference4 = Date().timeIntervalSince(self.URStart)
        let hours4 = Int(difference4) / 3600
        let minutes4 = (Int(difference4) / 60) % 60
        let second4 = (Int(difference4)) % 60
        self.URTime.text = "\(hours4) h \(minutes4) m \(second4) s"
        self.URStillTime = Int(difference4)
        let difference5 = Date().timeIntervalSince(self.MRStart)
        let hours5 = Int(difference5) / 3600
        let minutes5 = (Int(difference5) / 60) % 60
        let second5 = (Int(difference5)) % 60
        self.MRTime.text = "\(hours5) h \(minutes5) m \(second5) s"
        self.MRStillTime = Int(difference5)
        
        if(!self.bootsSwitchisOn){
        let difference6 = Date().timeIntervalSince(self.BRStart)
        let hours6 = Int(difference6) / 3600
        let minutes6 = (Int(difference6) / 60) % 60
        let second6 = (Int(difference6)) % 60
        self.BRTime.text = "\(hours6) h \(minutes6) m \(second6) s"
        self.BRStillTime = Int(difference6)
        }
        else{
            self.BRTime.text = "N/A"
            self.BRStart = Date()
        }
    }
    
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
