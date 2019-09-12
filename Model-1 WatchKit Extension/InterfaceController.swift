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

    // Variables
    let manager = CMMotionManager()
    
    var userDisplacementX = 0.0
    var userDisplacementY = 0.0
    var userDisplacementZ = 0.0
    
    var userInitialVelocityX = 0.0
    var userInitialVelocityY = 0.0
    var userInitialVelocityZ = 0.0
    
    var userVelocityX = 0.0
    var userVelocityY = 0.0
    var userVelocityZ = 0.0
    
    var currentTime = Date()
    
    let armLength = 10
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
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
                
                // v = u + at
                // s = ut + 1/2at^2
                
                // User velocity at time t
                self!.userVelocityX = self!.userInitialVelocityX + data.userAcceleration.x * 10.0 * Date().timeIntervalSince(self!.currentTime)
                self!.userVelocityY = self!.userInitialVelocityY + data.userAcceleration.y * 10.0 * Date().timeIntervalSince(self!.currentTime)
                self!.userVelocityZ = self!.userInitialVelocityZ + data.userAcceleration.z * 10.0 * Date().timeIntervalSince(self!.currentTime)
                
                // User distance at time t
                self!.userDisplacementX = ((self!.userVelocityX * Date().timeIntervalSince(self!.currentTime)) + (self!.userDisplacementX + data.userAcceleration.x * 10.0 * Date().timeIntervalSince(self!.currentTime) * Date().timeIntervalSince(self!.currentTime) / 2.0))
                self!.userDisplacementY = ((self!.userVelocityY * Date().timeIntervalSince(self!.currentTime)) + (self!.userDisplacementY + data.userAcceleration.y * 10.0 * Date().timeIntervalSince(self!.currentTime) * Date().timeIntervalSince(self!.currentTime) / 2.0))
                self!.userDisplacementZ = ((self!.userVelocityZ * Date().timeIntervalSince(self!.currentTime)) + (self!.userDisplacementZ + data.userAcceleration.z * 10.0 * Date().timeIntervalSince(self!.currentTime) * Date().timeIntervalSince(self!.currentTime) / 2.0))
                
                self!.currentTime = Date()
                
                self!.userInitialVelocityX = self!.userVelocityX
                self!.userInitialVelocityX = self!.userVelocityY
                self!.userInitialVelocityZ = self!.userVelocityZ
                
                print(data.userAcceleration, data.gravity)
                
//                print(self!.userDisplacementX, self!.userDisplacementY, self!.userDisplacementZ)
//                self!.manager.stopDeviceMotionUpdates()
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
        
        print(distX, distY, distZ)
        
        // Net Distance
        let finalDist = (distX*distX + distY*distY + distZ*distZ).squareRoot()
        print(finalDist)
        
        // Data Reset
        userDisplacementX = 0.0
        userDisplacementY = 0.0
        userDisplacementZ = 0.0
        
        userInitialVelocityX = 0.0
        userInitialVelocityY = 0.0
        userInitialVelocityZ = 0.0
        
        userVelocityX = 0.0
        userVelocityY = 0.0
        userVelocityZ = 0.0
    }
    
}


extension Double
{
    func truncate(places : Int) -> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}
