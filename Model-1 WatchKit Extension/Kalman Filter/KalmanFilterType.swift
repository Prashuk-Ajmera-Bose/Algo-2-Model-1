//
//  KalmanFilterType.swift
//  Model-1 WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/16/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import Foundation

// MARK: protocol KalmanInput
public protocol KalmanInput {
    // A -> A^T
    var transposed: Self { get }
    
    // A -> A^-1
    var inversed: Self { get }
    
    // A -> 1-A
    var additionToUnit: Self { get }
    
    // Mathematics functions
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
}

// MARK: protocol KalmanFilterType
public protocol KalmanFilterType {
    associatedtype Input: KalmanInput
    
    var stateEstimatePrior: Input { get }
    var errorCovariancePrior: Input { get }
    
    func predict(stateTransitionModel: Input, controlInputModel: Input, controlVector: Input, covarianceOfProcessNoise: Input) -> Self
    func update(measurement: Input, observationModel: Input, covarienceOfObservationNoise: Input) -> Self
}
