//
//  ViewController.swift
//  appname
//
//  Created by Marcus Tanner Miller on 3/22/20.
//  Copyright © 2020 Marcus Tanner Miller. All rights reserved.
//

import UIKit

class PlaceDescriptionView: UIViewController, UINavigationControllerDelegate {
    var pd :PlaceDescription = PlaceDescription()
    var isAdd: Bool = false
    var placeName: String = String()
    var urlString: String = String()
    
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var addressTitleTF: UITextField!
    @IBOutlet weak var addressStreetTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var zipCodeTF: UITextField!
    @IBOutlet weak var elevationTF: UITextField!
    @IBOutlet weak var latitudeTF: UITextField!
    @IBOutlet weak var longitudeTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        if let infoPlist = Bundle.main.infoDictionary {
            self.urlString = (infoPlist["ServerURLString"]) as!  String
            NSLog("The default urlString from info.plist is \(self.urlString)")
        }else{
            NSLog("error getting urlString from info.plist")
        }
        if(isAdd){
            saveButton.isHidden = false
            cancelButton.isHidden = false
        }
        else{
            get(placeName: placeName)
        }
        
    }
    
    @IBAction func cancelTouched(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func get(placeName: String){
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
                        self.pd = place
                        self.nameTF.text = self.pd.name
                        self.descriptionTF.text = self.pd.description
                        self.categoryTF.text = self.pd.category
                        self.addressTitleTF.text = self.pd.addressTitle
                        let addressStreetSplit = self.pd.addressStreet.split(separator: "\n")
                        switch addressStreetSplit.count{
                        case 4:
                            self.zipCodeTF.text = String(addressStreetSplit[3])
                            self.stateTF.text = String(addressStreetSplit[2])
                            self.cityTF.text = String(addressStreetSplit[1])
                            self.addressStreetTF.text = String(addressStreetSplit[0])
                        case 3:
                            self.zipCodeTF.text = ""
                            self.stateTF.text = String(addressStreetSplit[2])
                            self.cityTF.text = String(addressStreetSplit[1])
                            self.addressStreetTF.text = String(addressStreetSplit[0])
                        case 2:
                            self.zipCodeTF.text = ""
                            self.stateTF.text = ""
                            self.cityTF.text = String(addressStreetSplit[1])
                            self.addressStreetTF.text = String(addressStreetSplit[0])
                        case 1:
                            self.zipCodeTF.text = ""
                            self.stateTF.text = ""
                            self.cityTF.text = ""
                            self.addressStreetTF.text = String(addressStreetSplit[0])
                        default:
                            self.zipCodeTF.text = ""
                            self.stateTF.text = ""
                            self.cityTF.text = ""
                            self.addressStreetTF.text = ""
                        }
                        
                        
                        if(addressStreetSplit.count == 5){
                            self.countryTF.text = String(addressStreetSplit[4])
                        }
                        else{
                            self.countryTF.text = "USA"
                        }
                        self.elevationTF.text = String(self.pd.elevation)
                        self.latitudeTF.text = String(self.pd.latitude)
                        self.longitudeTF.text = String(self.pd.longitude)
                        
                    } catch {
                        NSLog("unable to convert to dictionary")
                    }
                }
            }
        })
    }
    
    func addPlace(place:PlaceDescription){
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
        let _:Bool = aConnect.add(place: place,callback: { _,_  in
            print("\(place.name) added as: \(place.toJsonString())")
        })
    }
    
    func deletePlace(place:String)->Bool{
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
        let ret:Bool = aConnect.remove(placeName: place,callback: { _,_  in
            })
        return ret
    }
    
    
    // If self is a navigation controller delegate (see above in view did load)
    // then this method will be called after the Nav Conroller back button click, but
    // before returning to the previous view. This provides an opportunity to update
    // that view's data with any changes from this view. This approach is
    // accepted practice for sending data back after a segue with nav controller.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        
        if let controller = viewController as? TableViewController {
            
            pd.name = nameTF.text ?? ""
            pd.description = descriptionTF.text ?? ""
            pd.category = categoryTF.text ?? ""
            pd.addressTitle = addressTitleTF.text ?? ""
            var tmp : String? = addressStreetTF.text ?? "\n"
            tmp! += cityTF.text! + "\n"
            tmp! += stateTF.text! + "\n"
            tmp! += zipCodeTF.text! + "\n"
            tmp! += countryTF.text!
            pd.addressStreet = tmp!
            pd.elevation = Double(elevationTF.text ?? "") ?? 0
            pd.latitude = Double(latitudeTF.text ?? "") ?? 0
            pd.longitude = Double(longitudeTF.text ?? "") ?? 0
            deletePlace(place: placeName)
            addPlace(place: pd)
            
        }
        
    }
    
    
    
    
}

