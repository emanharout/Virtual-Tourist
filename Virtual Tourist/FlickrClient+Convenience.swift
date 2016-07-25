
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

extension FlickrClient {
	
//    func downloadDataFromURL(photoURL: NSURL, completionHandler: (result: NSData?, error: NSError?)->Void) {
//        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
//        dispatch_async(queue) {
//            if let imageData = NSData(contentsOfURL: photoURL) {
//                completionHandler(result: imageData, error: nil)
//            } else {
//                let userInfo = ["NSUnderlyingErrorKey": "Failed to access image data from url: \(photoURL)"]
//                let error = NSError(domain: "downloadImages", code: 10, userInfo: userInfo)
//                completionHandler(result: nil, error: error)
//            }
//        }
//    }
	
	func downloadDataWithURL(photoURL: NSURL, completionHandler: (data: NSData?, error: NSError?)->Void) -> NSURLSessionDataTask {
		let task = NSURLSession.sharedSession().dataTaskWithURL(photoURL) {(data, response, error) in
			guard error == nil else {
				print("Error: \(error?.localizedDescription)")
				completionHandler(data: nil, error: error)
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				let userInfo = ["NSUnderlyingErrorKey": "Non 2xx status code"]
				let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
				completionHandler(data: nil, error: error)
				return
			}
			
			guard let data = data else {
				let userInfo = ["NSUnderlyingErrorKey": "No data retrieved from server"]
				let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
				completionHandler(data: nil, error: error)
				return
			}
			
			completionHandler(data: data, error: nil)
		}
		task.resume()
		return task
	}

	func getPhotoURLsWithLocation(latitude: Double, longitude: Double, pageNumber: Int, completionHandlerForSearchPhotos: (result: [NSURL]?, pages: Int?, error: NSError?)->Void) {
		let bbox = bboxCoordinate.sharedInstance.makeBbox(latitude, longitude: longitude)
		let scheme = FlickrClient.Constants.Scheme
		let host = FlickrClient.Constants.Host
		let path = FlickrClient.Constants.Path
		let parameters = [FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.FlickrAPI,
		                  FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.JSONFormat,
		                  FlickrClient.ParameterKeys.Method: FlickrClient.ParameterValues.PhotoSearchMethod,
		                  FlickrClient.ParameterKeys.NoJSONCallBack: FlickrClient.ParameterValues.NoJSONCallBack,
		                  FlickrClient.ParameterKeys.Extras: ParameterValues.imageURLMedium,
		                  FlickrClient.ParameterKeys.Page: String(pageNumber),
		                  FlickrClient.ParameterKeys.PerPage: FlickrClient.ParameterValues.ResultLimit,
		                  FlickrClient.ParameterKeys.Bbox: bbox]
		
		let url = buildURLWithComponents(scheme, host: host, path: path, parameters: parameters)
		
		taskForGETMethod(url) { (result, error) in
			if let error = error {
				completionHandlerForSearchPhotos(result: nil, pages: nil, error: error)
			} else {
				if let result = result as? [String: AnyObject] {
					guard let photosDict = result[FlickrClient.ResponseKeys.Photos] as? [String: AnyObject],
						let photosArray = photosDict[FlickrClient.ResponseKeys.Photo] as? [[String: AnyObject]],
						let maxPageNumber = photosDict[FlickrClient.ResponseKeys.MaxPage] as? Int else {
							let userInfo = ["NSUnderlyingErrorKey": "Could not access photos array"]
							let error = NSError(domain: "searchPhotosWithLocation", code: 10, userInfo: userInfo)
							completionHandlerForSearchPhotos(result: nil, pages: nil, error: error)
							return
					}
					
					var photoURLs = [NSURL]()
					for photo in photosArray {
						if let urlString = photo[FlickrClient.ResponseKeys.URL] as? String,
							let url = NSURL(string: urlString) {
							photoURLs.append(url)
						} else {
							print("No url found for photo")
						}
					}
					
					completionHandlerForSearchPhotos(result: photoURLs, pages: maxPageNumber, error: nil)
				}
			}
		}
	}

	
}