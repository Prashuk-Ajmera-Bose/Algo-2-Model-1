//
//  Extension.swift
//  Model-1 WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/18/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import Foundation

extension Double: KalmanInput {
    public var transposed: Double {
        return self
    }
    
    public var inversed: Double {
        return 1 / self
    }
    
    public var additionToUnit: Double {
        return 1 - self
    }
}

extension Double
{
//    func truncate(places: Int) -> Double {
//        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
//    }
//
//    func roundTo(places: Int) -> Double {
//        return Double((10 * places * self) / 1000)
//    }
}
