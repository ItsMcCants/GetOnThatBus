//
//  BusStop.swift
//  GetOnThatBus
//
//  Created by John McCants on 2/2/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

class BusStop: NSObject {
    
    let latitude: Double
    let longitude: Double
    let name: String
    let routes: String
    
    init(dict: NSDictionary) {
    
        let location = dict.objectForKey("location") as! NSDictionary
        self.latitude  = Double(location.objectForKey("latitude") as! String)!
        self.longitude = Double(location.objectForKey("longitude") as! String)!
        self.name      = dict.objectForKey("cta_stop_name") as! String
        self.routes    = dict.objectForKey("routes") as! String

    }
}
