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
    
    //UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sensor1: UILabel!
    @IBOutlet weak var sensor2: UILabel!
    @IBOutlet weak var sensor3: UILabel!
    @IBOutlet weak var sensor4: UILabel!
    @IBOutlet weak var sensor5: UILabel!
    @IBOutlet weak var sensor6: UILabel!
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.plain, target:nil, action:nil)
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
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
            
            if(aMessage.contains("#")){
                let start1 = aMessage.index(aMessage.startIndex, offsetBy: 1)
                let end1 = aMessage.index(aMessage.startIndex, offsetBy: 4)
                let range1 = start1..<end1
                self.sensor1.text = aMessage[range1]  // play
                
                let start2 = aMessage.index(aMessage.startIndex, offsetBy: 4)
                let end2 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                let range2 = start2..<end2
                self.sensor2.text = aMessage[range2]  // play
                
                let start3 = aMessage.index(aMessage.startIndex, offsetBy: 7)
                let end3 = aMessage.index(aMessage.startIndex, offsetBy: 10)
                let range3 = start3..<end3
                self.sensor3.text = aMessage[range3]  // play
                
                let start4 = aMessage.index(aMessage.startIndex, offsetBy: 10)
                let end4 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                let range4 = start4..<end4
                self.sensor4.text = aMessage[range4]  // play
                
                let start5 = aMessage.index(aMessage.startIndex, offsetBy: 13)
                let end5 = aMessage.index(aMessage.startIndex, offsetBy: 16)
                let range5 = start5..<end5
                self.sensor5.text = aMessage[range5]  // play
                
                let start6 = aMessage.index(aMessage.startIndex, offsetBy: 16)
                let end6 = aMessage.index(aMessage.startIndex, offsetBy: 19)
                let range6 = start6..<end6
                self.sensor6.text = aMessage[range6]  // play
            }
            self.consoleAsciiText = newAsciiText
            
            // add head image
            let headimageName = "bluehead.png"
            let headimage = UIImage(named: headimageName)
            let headimageView = UIImageView(image: headimage!)
            
            headimageView.frame = CGRect(x: 500, y: 100, width: 100, height: 85)
            self.view.addSubview(headimageView)
            
            // add body image
            let bodyimageName = "bodyblue.png"
            let bodyimage = UIImage(named: bodyimageName)
            let bodyimageView = UIImageView(image: bodyimage!)
            
            bodyimageView.frame = CGRect(x: 402, y: 185, width: 300, height: 300)
            self.view.addSubview(bodyimageView)
            // add hip image
            let hipimageName = "legblue.png"
            let hipimage = UIImage(named: hipimageName)
            let hipimageView = UIImageView(image: hipimage!)
            
            hipimageView.frame = CGRect(x: 482, y: 327, width: 130, height: 250)
            self.view.addSubview(hipimageView)
            // add leg image
            let feetimageName = "feetblue.png"
            let feetimage = UIImage(named: feetimageName)
            let feetimageView = UIImageView(image: feetimage!)
            
            feetimageView.frame = CGRect(x: 390, y: 540, width: 290, height: 250)
            self.view.addSubview(feetimageView)
        }
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
}

