
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

class Client: NSObject {
  
  func buildURLWithComponents(_ scheme: String, host: String, path: String, parameters: NSDictionary) -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = path
    urlComponents.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
      let queryItem = URLQueryItem(name: "\(key)", value: "\(value)")
      urlComponents.queryItems?.append(queryItem)
    }
    
    print("\(urlComponents.url!)")
    return urlComponents.url!
  }
  
  func parseData(_ data: Data, completionHandler: (_ result: Any?, _ error: NSError?)-> Void) {
    let parsedResult: Any!
    
    do {
      parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      print("Parsed Data: \(parsedResult)")
    } catch {
      let userInfo = ["NSUnderlyingErrorKey":"Failure to Parse Data."]
      let error = NSError(domain: "parseData", code: 10, userInfo: userInfo)
      completionHandler(nil, error)
      
      return
    }
    
    completionHandler(parsedResult, nil)
  }
}
