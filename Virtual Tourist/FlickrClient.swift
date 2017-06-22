
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

class FlickrClient: Client {
  
  static let sharedInstance = FlickrClient()
  
  func taskForGETMethod(_ url: URL, completionHandlerForTask: @escaping (_ result: Any?, _ error: NSError?)->Void) -> URLSessionDataTask {
    let request = URLRequest(url: url)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
      
      guard error == nil else {
        print("Error: \(String(describing: error?.localizedDescription))")
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
        let userInfo = ["NSUnderlyingErrorKey": "Non 2xx status code"]
        let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
        completionHandlerForTask(nil, error)
        return
      }
      
      guard let data = data else {
        let userInfo = ["NSUnderlyingErrorKey": "No data retrieved from server"]
        let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
        completionHandlerForTask(nil, error)
        return
      }
      
      self.parseData(data, completionHandler: completionHandlerForTask)
    })
    task.resume()
    return task
  }
  
  fileprivate override init() {
  }
}

extension FlickrClient {
  
  struct Constants {
    static let Scheme = "https"
    static let Host = "api.flickr.com"
    static let Path = "/services/rest/"
  }
  
  struct ParameterKeys {
    static let APIKey = "api_key"
    static let Method = "method"
    static let Format = "format"
    static let NoJSONCallBack = "nojsoncallback"
    static let Bbox = "bbox"
    static let Extras = "extras"
    static let Page = "page"
    static let PerPage = "per_page"
  }
  
  struct ParameterValues {
    static let FlickrAPI = "21fb1f6af6d473535c8187d3e72f4dc4"
    static let PhotoSearchMethod = "flickr.photos.search"
    static let JSONFormat = "json"
    static let NoJSONCallBack = "1"
    static let imageURLMedium = "url_m"
    static let ResultLimit = "21"
  }
  
  struct ResponseKeys {
    static let Photos = "photos"
    static let Photo = "photo"
    static let URL = "url_m"
    static let MaxPage = "pages"
  }
  
}
