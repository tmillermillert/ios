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
 * Purpose: Swift Client for a Java student collection JsonRPC server.
 *
 * @author Marcus Miller mtmille5@asu.edu
 * @version April, 2020
 
 public String[] getNames();          //get a string array of titles kwown to the server
 public boolean resetFromJsonFile();  //reset the library to its original contents
 public boolean saveToJsonFile();     //save the library to a json file
 public String[] getCategoryNames();  //get category names for library places
 public boolean add(Item anItem);     //add a new place to the library
 public PlaceDescription get(String aName);       //get the named place
 public boolean remove(String aName); //remove the place named
 public String[] getNamesInCategory(String aCat); //get place names within a category
 */

import Foundation

public class PlaceLibraryStub {
    
    static var id:Int = 0
    
    var url:String
    
    init(urlString: String){
        self.url = urlString
    }
    
    // used by methods below to send a request asynchronously.
    // creates and posts a URLRequest that attaches a JSONRPC request as a Data object. The URL session
    // executes in the background and calls its completion handler when the result is available.
    func asyncHttpPostJSON(url: String,  data: Data,
                           completion: @escaping (String, String?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.httpBody = data as Data
        //HTTPsendRequest(request: request, callback: completion)
        // task.resume() below, causes the shared session http request to be posted in the background
        // (independent of the UI Thread)
        // the use of the DispatchQueue.main.async causes the callback to occur on the main queue --
        // where the UI can be altered, and it occurs after the result of the post is received.
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if (error != nil) {
                completion("Error in URL Session", error!.localizedDescription)
            } else {
                DispatchQueue.main.async(execute: {completion(NSString(data: data!,
                                                                       encoding: String.Encoding.utf8.rawValue)! as String, nil)})
            }
        })
        task.resume()
    }

    func getNames(callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"getNames", "params":[ ], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    
    func resetFromJsonFile(callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"resetFromJsonFile", "params":[ ], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func saveToJsonFile(callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"saveToJsonFile", "params":[ ], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func getCategoryNames(callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"getCategoryNames", "params":[ ], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func add(place: PlaceDescription, callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"add", "params":[place.toDict()], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func get(placeName: String, callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"get", "params":[placeName], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func remove(placeName: String, callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"remove", "params":[placeName], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func getNamesInCategory(aCat: String, callback: @escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        PlaceLibraryStub.id = PlaceLibraryStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"getNamesInCategory", "params":[aCat], "id":PlaceLibraryStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url: self.url, data: reqData, completion: callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
}
