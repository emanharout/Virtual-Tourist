
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

struct bboxCoordinate {
    
    static let sharedInstance = bboxCoordinate()
    
    static let searchLongRange = (min: -180.0, max: 180.0)
    static let searchLatRange = (min: -90.0, max: 90.0)
    let halfDiameter = 0.5
    
    func makeBbox(latitude: Double, longitude: Double)-> String {
        
        if latitude > bboxCoordinate.searchLatRange.max || latitude < bboxCoordinate.searchLatRange.min || longitude > bboxCoordinate.searchLongRange.max || longitude < bboxCoordinate.searchLongRange.min {
            print("Invalid latitude or longitude value")
            return ""
        }
        
        let bboxMinLat: Double
        let bboxMinLong: Double
        let bboxMaxLat: Double
        let bboxMaxLong: Double
        
        bboxMinLat = max(latitude - halfDiameter, bboxCoordinate.searchLatRange.min)
        bboxMaxLat = min(latitude + halfDiameter, bboxCoordinate.searchLatRange.max)
        
        let testMinLong = longitude - halfDiameter
        let testMaxLong = longitude + halfDiameter
        bboxMinLong = (testMinLong < bboxCoordinate.searchLongRange.min) ? testMinLong + 360.0 : testMinLong
        bboxMaxLong = (testMaxLong > bboxCoordinate.searchLongRange.max) ? testMaxLong - 360.0 : testMaxLong
        
        let bboxString = "\(bboxMinLong), \(bboxMinLat), \(bboxMaxLong), \(bboxMaxLat)"
        return bboxString
    }

    private init(){}
}
