//
//  Client.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/12/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

class Client: NSObject {
    
    func buildURLWithComponents(scheme: String, host: String, path: String, parameters: NSDictionary) -> NSURL {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: "\(key)", value: "\(value)")
            urlComponents.queryItems?.append(queryItem)
        }
        
        print("\(urlComponents.URL!)")
        return urlComponents.URL!
    }

    func parseData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?)-> Void) {
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print("Parsed Data: \(parsedResult)")
        } catch {
            let userInfo = ["NSUnderlyingErrorKey":"Failure to Parse Data."]
            let error = NSError(domain: "parseData", code: 10, userInfo: userInfo)
            completionHandler(result: nil, error: error)

            return
        }

        completionHandler(result: parsedResult, error: nil)
    }
}
