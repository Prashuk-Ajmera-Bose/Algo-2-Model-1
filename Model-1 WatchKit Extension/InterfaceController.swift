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
    
//    let tau = 0.75
//    let dt = 60
//    let alpha = tau / (self.tau + self.dt)
    
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
                
                
                let deltaTime = Date().timeIntervalSince(self!.currentTime)
                self!.totalTime = self!.totalTime + deltaTime
                                
                // s = ut + 1/2at^2
                // v = u + at
                                
                // User displacements after deltaTime
                self!.userDisplacementX = (self!.userDisplacementX + ((self!.userInitialVelocityX * deltaTime) + (data.userAcceleration.x * 9.8 * deltaTime * deltaTime / 2)))
                self!.userDisplacementY = (self!.userDisplacementY + ((self!.userInitialVelocityY * deltaTime) + (data.userAcceleration.y * 9.8 * deltaTime * deltaTime / 2)))
                self!.userDisplacementZ = (self!.userDisplacementZ + ((self!.userInitialVelocityZ * deltaTime) + (data.userAcceleration.z * 9.8 * deltaTime * deltaTime / 2)))
                                
                // Replacing initial velocities with final velocities for the next step
                self!.userInitialVelocityX = self!.userInitialVelocityX + data.userAcceleration.x * 9.8 * deltaTime
                self!.userInitialVelocityY = self!.userInitialVelocityY + data.userAcceleration.y * 9.8 * deltaTime
                self!.userInitialVelocityZ = self!.userInitialVelocityZ + data.userAcceleration.z * 9.8 * deltaTime
                                
                self!.currentTime = Date()
                
//                if (data.gravity.x > 0.85) {
//                    self!.manager.stopDeviceMotionUpdates()
//                    self!.deviceMotionData()
//                }
                                
                print("\(self!.userDisplacementX)   \(self!.userDisplacementY)  \(self!.userDisplacementZ)  \(self!.totalTime)")

            } 
        }
    }
    
    @IBAction func getImu() {
        currentTime = Date()
        deviceMotionData()
    }
    
    @IBAction func stopMotion() {
        manager.stopDeviceMotionUpdates()
        
        let distX = userDisplacementX
        let distY = userDisplacementY
        let distZ = userDisplacementZ
        
        print("FX= \(distX), FY= \(distY), FZ= \(distZ)")
        
        // Net Distance
        let finalDist = (distX*distX + distY*distY + distZ*distZ).squareRoot()
        
        // Angle calculation
        let angleX = distX / armLength
        let angleY = distY / armLength
        let angleZ = distZ / armLength
        
        //print(angleX, angleY, angleZ)
        
        // Data Reset
        userDisplacementX = 0.00
        userDisplacementY = 0.00
        userDisplacementZ = 0.00
        
        userInitialVelocityX = 0.00
        userInitialVelocityY = 0.00
        userInitialVelocityZ = 0.00
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
