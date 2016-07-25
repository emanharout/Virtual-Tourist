

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var task: NSURLSessionTask? {
		didSet {
			if let previousTask = oldValue {
				previousTask.cancel()
			}
		}
	}
    
}
