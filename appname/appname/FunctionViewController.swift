//
//  FunctionViewController.swift
//  appname
//
//  Created by Marcus Tanner Miller on 4/16/20.
//  Copyright © 2020 Marcus Tanner Miller. All rights reserved.
//

import UIKit

class FunctionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var placeNames : [String]?
    var functions : [String] = ["Great Circle Sperical Distance", "Initial Heading"]
    var startPD: PlaceDescription = PlaceDescription()
    var endPD: PlaceDescription = PlaceDescription()
    var urlString: String = String()
    
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var functionPicker: UIPickerView!
    @IBOutlet weak var startLocationPicker: UIPickerView!
    @IBOutlet weak var endLocationPicker: UIPickerView!
    @IBOutlet weak var submitButton: UIButton!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func getNames(){
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
        let _:Bool = aConnect.getNames(callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8){
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        self.placeNames = (dict!["result"] as? [String])!
                        self.startLocationPicker.reloadComponent(0)
                        self.endLocationPicker.reloadComponent(0)
                    } catch {
                        print("unable to convert to dictionary")
                    }
                }
                
            }
        })  // end of method call to getNames
    }
    
    func get(placeName: String, isStart: Bool, function: Int){
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
        let _:Bool = aConnect.get(placeName: placeName, callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8){
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
                        let place:PlaceDescription = PlaceDescription(dict: aDict)
                        if isStart {
                            self.startPD = place
                        }
                        else{
                            self.endPD = place
                        }
                        var x: Double = 0.0
                        if(function == 0){
                            x = self.startPD.greatCircleSphericalDistance(pd1: self.startPD, pd2: self.endPD)
                        }
                        else if (function == 1){
                            x = self.startPD.initialHeading(pd1: self.startPD, pd2: self.endPD)
                        }
                        else{
                            return
                        }
                        self.result.text = "Result: " + String(x)
                        self.submitButton.isEnabled = true
                        
                    } catch {
                        NSLog("unable to convert to dictionary")
                    }
                }
            }
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == functionPicker){
            return 2
        }
        else{
            return placeNames?.count ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == functionPicker){
            return functions[row]
        }
        else if(pickerView == startLocationPicker){
            return placeNames![row]
        }
        else{
            return placeNames![row]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        functionPicker.dataSource = self
        functionPicker.delegate = self
        startLocationPicker.dataSource = self
        startLocationPicker.delegate = self
        endLocationPicker.dataSource = self
        endLocationPicker.delegate = self
        if let infoPlist = Bundle.main.infoDictionary {
            self.urlString = (infoPlist["ServerURLString"]) as!  String
            NSLog("The default urlString from info.plist is \(self.urlString)")
        }else{
            NSLog("error getting urlString from info.plist")
        }
        getNames()
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let start = startLocationPicker.selectedRow(inComponent: 0)
        let end = endLocationPicker.selectedRow(inComponent: 0)
        if (placeNames!.count == 0){
            return
        }
        submitButton.isEnabled = false
        get(placeName: placeNames![start], isStart: true, function: -1)
        get(placeName: placeNames![end], isStart: false, function: functionPicker.selectedRow(inComponent: 0))

    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
