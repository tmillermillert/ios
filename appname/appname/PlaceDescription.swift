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
 * Purpose: For our purposes a place is a simplified holder for information about geographic places of interest, such as a waypoint
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Marcus Miller mailto:mtmille5@asu.edu
 * @version April 2020
 */

import Foundation
import simd

class PlaceDescription {
    //A simple string, which is unique among all names of places for this user. Usually one or two words.
    var name: String
    //Text providing descriptive information about the place.
    var description: String
    //Text describing the type of place this entry describes. Sample categories are residence, travel, and hike.
    var category: String
    //This field is equivalent to the first line that would appear in an address, sometimes called the recipient line. It indicates the individual or organization to which the address pertains. This field is generally not used in a geocoding lookup.
    var addressTitle: String
    //The rest of an address. This includes the street address, city or town, the state and optionally country and/or zip code. Although the examples indicate otherwise, you may assume USA address format only.
    var addressStreet: String
    // Feet mean sea level elevation of the place. This field is also generally not used in geocoding services, but is useful in route planning.
    var elevation: Double
    //Degrees latitude, using a single double value to represent. Lines of equal latitude run parallel to the Equator. Values range from -90.0 to +90.0. Negative values refer to the southern hemisphere and positive values to the northern hemisphere.
    var latitude: Double
    //Degrees of longitude, using a single double value. Values range from -180.0 to +180.0. Lines of equal longitude run perpendicular to the Equator. Negative values increase west from the Prime Meridian, which is longitude 0.0 and is located in Greenwich England. Positive values increase east from the Prime Meridian. 180.0 (plus and minus) is the International Date Line.
    var longitude: Double

    init(){
        name = ""
        description = ""
        category = ""
        addressTitle = ""
        addressStreet = ""
        elevation = 0
        latitude = 0
        longitude = 0
    }
    
    func greatCircleSphericalDistance(pd1: PlaceDescription, pd2: PlaceDescription) -> Double{
        let R = 6371e3; // metres
        let φ1: Double = pd1.latitude * .pi / 180
        let φ2: Double = pd2.latitude * .pi / 180
        let Δφ: Double = (pd2.latitude-pd1.latitude) * .pi / 180;
        let Δλ: Double = (pd2.longitude-pd1.longitude) * .pi / 180;

        let a: Double = sin(Δφ/2) * sin(Δφ/2) +
        cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2);
        let c: Double = 2 * atan2(a.squareRoot(), (1-a).squareRoot())

        let d = R * c;
        return d
    }
    
    func initialHeading(pd1: PlaceDescription, pd2: PlaceDescription) -> Double{
        let φ1: Double = pd1.latitude * .pi / 180
        let φ2: Double = pd2.latitude * .pi / 180
        let λ1: Double = pd1.longitude * .pi / 180
        let λ2: Double = pd2.longitude * .pi / 180
        let y = sin(λ2 - λ1) * cos(φ2);
        let x = cos(φ1) * sin(φ2) -
                sin(φ1) * cos(φ2) * cos(λ2-λ1);
        let θ = atan2(y, x)
        let brng = (θ * 180 / .pi + 360)
        var brng2 = brng
        while(brng2 > 360){
            brng2 -= 360
        }
        return brng2
    }
    
    init (jsonStr: String){
        name = ""
        description = ""
        category = ""
        addressTitle = ""
        addressStreet = ""
        elevation = 0
        latitude = 0
        longitude = 0
        if let data: Data = jsonStr.data(using: String.Encoding.utf8){
            do{
                let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:Any]
                name = (dict!["name"] as? String)!
                description = (dict!["description"] as? String)!
                category = (dict!["category"] as? String)!
                addressTitle = (dict!["address-title"] as? String)!
                addressStreet = (dict!["address-street"] as? String)!
                elevation = (dict!["elevation"] as? Double)!
                latitude = (dict!["latitude"] as? Double)!
                longitude = (dict!["longitude"] as? Double)!
            } catch {
                print("unable to convert to dictionary")
                print(error)
            }
        }
    }
    
    func toJsonString() -> String {
        var jsonStr = "";
        let dict:[String:Any] = ["name": name, "description": description, "category": category, "addressTitle": addressStreet, "addressStreet": addressStreet, "elevation": elevation, "latitude": latitude, "longitude": longitude] as [String : Any]
        do {
            let jsonData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch let error as NSError {
            print(error)
        }
        return jsonStr
    }
    
    func toDict() -> [String:Any] {
        let dict = ["name" : name,
                    "description" : description,
                    "category" : category,
                    "addressTitle" : addressTitle,
                    "addressStreet" : addressStreet,
                    "elevation" : elevation,
                    "latitude" : latitude,
                    "longitude" : longitude] as [String : Any]
        return dict
    }
    
    init(dict: [String:Any]){
        self.name = dict["name"] as? String ?? ""
        self.description = dict["description"] as? String ?? ""
        self.category = dict["category"] as? String ?? ""
        self.addressTitle = dict["address-title"] as? String ?? ""
        self.addressStreet = dict["address-street"] as? String ?? ""
        self.elevation = dict["elevation"] as? Double ?? 0
        self.latitude = dict["latitude"] as? Double ?? 0
        self.longitude = dict["longitude"] as? Double ?? 0
    }
    
}

