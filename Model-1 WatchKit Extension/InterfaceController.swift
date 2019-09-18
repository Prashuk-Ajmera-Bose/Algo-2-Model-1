//
//  InterfaceController.swift
//  Model-1 WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/10/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import os

class InterfaceController: WKInterfaceController {

    let manager = CMMotionManager()
    
    var userDisplacementX: Double = 0.00
    var userDisplacementY: Double = 0.00
    var userDisplacementZ: Double = 0.00
    
    var userInitialVelocityX: Double = 0.00
    var userInitialVelocityY: Double = 0.00
    var userInitialVelocityZ: Double = 0.00

    var userAccelerationX: Double = 0.00
    
    var currentTime = Date()
    
    let armLength: Double = 10.00 // assume
    
    var totalTime = 0.00
    var deltaTime = 0.00
    var flag = 0
        
    var filterX = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)
    var filterY = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)
    var filterZ = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func deviceMotionData() {
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 1 / 60
            manager.startDeviceMotionUpdates(to: .main) {
                
                [weak self] (data, error) in
                guard let data = data, error == nil else {
                    return
                }
                
                if self!.flag == 0 {
                    self!.deltaTime = 0.00
                    self!.flag = 1
                } else {
                    self!.deltaTime = Date().timeIntervalSince(self!.currentTime)
                }
                
                self!.totalTime = self!.totalTime + self!.deltaTime
                                
                // s = ut + 1/2at^2
                // v = u + at
                                
                // User displacements after deltaTime
                self!.userDisplacementX = (self!.userDisplacementX) + ((self!.userInitialVelocityX * self!.deltaTime) + (data.userAcceleration.x * 9.8 * self!.deltaTime * self!.deltaTime / 2))
                self!.userDisplacementY = (self!.userDisplacementY) + ((self!.userInitialVelocityY * self!.deltaTime) + (data.userAcceleration.y * 9.8 * self!.deltaTime * self!.deltaTime / 2))
                self!.userDisplacementZ = (self!.userDisplacementZ) + ((self!.userInitialVelocityZ * self!.deltaTime) + (data.userAcceleration.z * 9.8 * self!.deltaTime * self!.deltaTime / 2))
                                
                // Replacing initial velocities with final velocities for the next step
                self!.userInitialVelocityX = self!.userInitialVelocityX + data.userAcceleration.x * 9.8 * self!.deltaTime
                self!.userInitialVelocityY = self!.userInitialVelocityY + data.userAcceleration.y * 9.8 * self!.deltaTime
                self!.userInitialVelocityZ = self!.userInitialVelocityZ + data.userAcceleration.z * 9.8 * self!.deltaTime
                                
                self!.currentTime = Date()
                
//                if (data.gravity.x > 0.85) {
//                    self!.manager.stopDeviceMotionUpdates()
//                    self!.deviceMotionData()
//                }
                
                let predictionX = self!.filterX.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
                let updateX = predictionX.update(measurement: self!.userDisplacementX, observationModel: 1, covarienceOfObservationNoise: 0.1)
                
                let predictionY = self!.filterY.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
                let updateY = predictionY.update(measurement: self!.userDisplacementY, observationModel: 1, covarienceOfObservationNoise: 0.1)
                
                let predictionZ = self!.filterZ.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
                let updateZ = predictionZ.update(measurement: self!.userDisplacementZ, observationModel: 1, covarienceOfObservationNoise: 0.1)
                
                self!.filterX = updateX
                self!.filterY = updateY
                self!.filterZ = updateZ
                
                print("Without Kalman   \(self!.userDisplacementX)  \(self!.userDisplacementY)  \(self!.userDisplacementZ)  \(self!.deltaTime)  \(self!.totalTime)")
                print("With Kalman      \(self!.filterX.stateEstimatePrior) \(self!.filterY.stateEstimatePrior) \(self!.filterZ.stateEstimatePrior) \(self!.deltaTime)  \(self!.totalTime)")
                print()

            } 
        }
    }
    
    @IBAction func getImu() {
        deviceMotionData()
    }
    
    @IBAction func stopMotion() {
        manager.stopDeviceMotionUpdates()
        
        let distX = userDisplacementX
        let distY = userDisplacementY
        let distZ = userDisplacementZ
        
        print("FX= \(distX), FY= \(distY), FZ= \(distZ)")
        
//        // Net Distance
//        let finalDist = (distX*distX + distY*distY + distZ*distZ).squareRoot()
//
//        // Angle calculation
//        let angleX = distX / armLength
//        let angleY = distY / armLength
//        let angleZ = distZ / armLength
//
//        //print(angleX, angleY, angleZ)
//
//        // Data Reset
//        userDisplacementX = 0.00
//        userDisplacementY = 0.00
//        userDisplacementZ = 0.00
//
//        userInitialVelocityX = 0.00
//        userInitialVelocityY = 0.00
//        userInitialVelocityZ = 0.00
    }
    
}
