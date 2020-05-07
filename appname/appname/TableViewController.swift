/*
* Copyright 2020 Marcus Miller,
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* Purpose: Main menu view to display place descriptions. Click on a list item to modify a place description. Click on the plus menu option to add a place description. Click on the navigation menu item to calculate the Great Circle Sperical Distance and Initial Heading. Swipe a list item to delete that item. The place JSONRPC server must be running.
*
* Ser423 Mobile Applications
* see http://pooh.poly.asu.edu/Mobile
* @author Marcus Miller mailto:mtmille5@asu.edu
* @version April 2020
*/

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
    
    @IBAction func resetJsonRPCServer(_ sender: Any) {
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
        let _:Bool = aConnect.resetFromJsonFile(callback: { _,_  in self.getNames()})
    }
    
    @IBAction func saveJsonRPCServer(_ sender: Any) {
        let aConnect:PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
        let _:Bool = aConnect.saveToJsonFile(callback: {_,_  in return true})
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
        
        source.pd.addressStreet = source.addressStreetTF.text! + "\n"
        source.pd.elevation = Double(source.elevationTF.text ?? "") ?? 0
        source.pd.latitude = Double(source.latitudeTF.text ?? "") ?? 0
        source.pd.longitude = Double(source.longitudeTF.text ?? "") ?? 0
        viewController.addPlace(place: source.pd)
    }
}
