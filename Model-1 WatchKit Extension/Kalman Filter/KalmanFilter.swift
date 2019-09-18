//
//  KalmanFilter.swift
//  Model-1 WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/16/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import Foundation

public struct KalmanFilter<Type: KalmanInput>: KalmanFilterType {
    
    // x̂_k|k-1
    public let stateEstimatePrior: Type
    
    // P_k|k-1
    public let errorCovariancePrior: Type
    
    public init(stateEstimatePrior: Type, errorCovariancePrior: Type) {
        self.stateEstimatePrior = stateEstimatePrior
        self.errorCovariancePrior = errorCovariancePrior
    }
    
    /*
     Predict step in Kalman filter.
     
     - parameter stateTransitionModel: F_k
     - parameter controlInputModel: B_k
     - parameter controlVector: u_k-1
     - parameter covarianceOfProcessNoise: Q_k
     
     - returns: Another instance of Kalman filter with predicted x̂_k and P_k
     */
    public func predict(stateTransitionModel: Type, controlInputModel: Type, controlVector: Type, covarianceOfProcessNoise: Type) -> KalmanFilter {
        // x̂_k|k-1 = F_k * x̂_k-1|k-1 + B_k * u_k-1
        let predictedStateEstimate = stateTransitionModel * stateEstimatePrior + controlInputModel * controlVector
        
        // P_k|k-1 = F_k * P_k-1|k-1 * F_k^T + Q_k
        let predictedEstimateCovariance = stateTransitionModel * errorCovariancePrior * stateTransitionModel.transposed + covarianceOfProcessNoise
        
        return KalmanFilter(stateEstimatePrior: predictedStateEstimate, errorCovariancePrior: predictedEstimateCovariance)
    }
    
    /*
     Update step in Kalman filter.
     
     - parameter measurement: z_k
     - parameter observationModel: H_k
     - parameter covarienceOfObservationNoise: R_k
     
     - returns: Updated with the measurements version of Kalman filter with new x̂_k and P_k
     */
    public func update(measurement: Type, observationModel: Type, covarienceOfObservationNoise: Type) -> KalmanFilter {
        // ỹ_k = z_k - H_k * x̂_k|k-1
        let measurementResidual = measurement - observationModel * stateEstimatePrior
        
        // S_k = H_k * P_k|k-1 * H_k^t + R_k
        let residualCovariance = observationModel * errorCovariancePrior * observationModel.transposed + covarienceOfObservationNoise
        
        // K_k = P_k|k-1 * H_k^t * S_k^-1
        let kalmanGain = errorCovariancePrior * observationModel.transposed * residualCovariance.inversed
        
        // x̂_k|k = x̂_k|k-1 + K_k * ỹ_k
        let posterioriStateEstimate = stateEstimatePrior + kalmanGain * measurementResidual
        
        // P_k|k = (I - K_k * H_k) * P_k|k-1
        let posterioriEstimateCovariance = (kalmanGain * observationModel).additionToUnit * errorCovariancePrior
        
        return KalmanFilter(stateEstimatePrior: posterioriStateEstimate, errorCovariancePrior: posterioriEstimateCovariance)
    }
    
}
