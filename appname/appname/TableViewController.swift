//
//  TableViewController.swift
//  appname
//
//  Created by Marcus Tanner Miller on 4/9/20.
//  Copyright © 2020 Marcus Tanner Miller. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var placeNames: [String] = [String]()
    var urlString : String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let infoPlist = Bundle.main.infoDictionary {
            self.urlString = (infoPlist["ServerURLString"]) as!  String
            NSLog("The default urlString from info.plist is \(self.urlString)")
        }else{
            NSLog("error getting urlString from info.plist")
        }
        getNames()
        
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
                        self.tableView.reloadData()
                    } catch {
                        print("unable to convert to dictionary")
                    }
                }
                
            }
        })  // end of method call to getNames
    }
    
    func deletePlace(place:String, indexPath:IndexPath)->Bool{
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
        let ret:Bool = aConnect.remove(placeName: place,callback: { _,_  in
            self.placeNames.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            })
        return ret
    }
    
    func addPlace(place:PlaceDescription){
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
        let _:Bool = aConnect.add(place: place,callback: { _,_  in
            print("\(place.name) added as: \(place.toJsonString())")
            self.getNames()})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placeNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! TableViewCell
        cell.placeCellTitle.text = placeNames[indexPath.row]
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deletePlace(place: placeNames[indexPath.row], indexPath:indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addPlace" {
            let viewController:PlaceDescriptionView = segue.destination as! PlaceDescriptionView
            viewController.isAdd = true
        }
        else if segue.identifier == "editPlace"{
            let viewController:PlaceDescriptionView = segue.destination as! PlaceDescriptionView
            viewController.isAdd = false
            viewController.placeName =  placeNames[self.tableView.indexPathForSelectedRow!.row]
        }
        else if segue.identifier == "function"{
            
        }
    }
    

    @IBAction func unwindToTable(segue: UIStoryboardSegue){
        let viewController = segue.destination as! TableViewController
        let source = segue.source as! PlaceDescriptionView
        source.pd.name = source.nameTF.text ?? ""
        if( source.pd.name.count == 0){
            getNames()
            source.pd.name = String(placeNames.count)
        }
        source.pd.description = source.descriptionTF.text ?? ""
        source.pd.category = source.categoryTF.text ?? ""
        source.pd.addressTitle = source.addressTitleTF.text ?? ""
        
        source.addressStreetTF.text = source.addressStreetTF.text ?? " "
        source.cityTF.text = source.cityTF.text ?? " "
        source.stateTF.text = source.stateTF.text ?? " "
        source.zipCodeTF.text = source.zipCodeTF.text ?? " "
        source.countryTF.text = source.countryTF.text ?? " "
        
        source.pd.addressStreet = source.addressStreetTF.text! + "\n"
        source.pd.addressStreet += source.cityTF.text! + "\n"
        source.pd.addressStreet += source.stateTF.text! + "\n"
        source.pd.addressStreet += source.zipCodeTF.text! + "\n"
        source.pd.addressStreet += source.countryTF.text!
        source.pd.elevation = Double(source.elevationTF.text ?? "") ?? 0
        source.pd.latitude = Double(source.latitudeTF.text ?? "") ?? 0
        source.pd.longitude = Double(source.longitudeTF.text ?? "") ?? 0
        viewController.addPlace(place: source.pd)
    }
}
