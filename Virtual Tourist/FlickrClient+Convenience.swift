
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

extension FlickrClient {
	
	func downloadDataWithURL(_ photoURL: URL, completionHandler: @escaping (_ data: Data?, _ error: NSError?)->Void) -> URLSessionDataTask {
		let task = URLSession.shared.dataTask(with: photoURL, completionHandler: {(data, response, error) in
			guard error == nil else {
				print("Error: \(String(describing: error?.localizedDescription))")
				completionHandler(nil, error as NSError?)
				return
			}
			
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
				let userInfo = ["NSUnderlyingErrorKey": "Non 2xx status code"]
				let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
				completionHandler(nil, error)
				return
			}
			
			guard let data = data else {
				let userInfo = ["NSUnderlyingErrorKey": "No data retrieved from server"]
				let error = NSError(domain: "taskForGETMethod", code: 10, userInfo: userInfo)
				completionHandler(nil, error)
				return
			}
			
			completionHandler(data, nil)
		})
		task.resume()
		return task
	}
	
	func getPhotoURLsWithLocation(_ latitude: Double, longitude: Double, pageNumber: Int, completionHandlerForSearchPhotos: @escaping (_ result: [URL]?, _ pages: Int?, _ error: NSError?)->Void) {
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
		
		let url = buildURLWithComponents(scheme, host: host, path: path, parameters: parameters as NSDictionary)
		
		_ = taskForGETMethod(url) { (result, error) in
			if let error = error {
				completionHandlerForSearchPhotos(nil, nil, error)
			} else {
				if let result = result as? [String: AnyObject] {
					guard let photosDict = result[FlickrClient.ResponseKeys.Photos] as? [String: AnyObject],
						let photosArray = photosDict[FlickrClient.ResponseKeys.Photo] as? [[String: AnyObject]],
						let maxPageNumber = photosDict[FlickrClient.ResponseKeys.MaxPage] as? Int else {
							let userInfo = ["NSUnderlyingErrorKey": "Could not access photos array"]
							let error = NSError(domain: "searchPhotosWithLocation", code: 10, userInfo: userInfo)
							completionHandlerForSearchPhotos(nil, nil, error)
							return
					}
					
					var photoURLs = [URL]()
					for photo in photosArray {
						if let urlString = photo[FlickrClient.ResponseKeys.URL] as? String,
							let url = URL(string: urlString) {
							photoURLs.append(url)
						} else {
							print("No url found for photo")
						}
					}
					
					completionHandlerForSearchPhotos(photoURLs, maxPageNumber, nil)
				}
			}
		}
	}
	
	
}
