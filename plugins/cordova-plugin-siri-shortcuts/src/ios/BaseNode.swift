//
//  BaseNode.swift
//  ARKitDemoApp
//
//  Created by Aman Singh on 8/27/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import SceneKit
import UIKit
import ARKit
import CoreLocation

@available(iOS 11.0, *)
class BaseNode: SCNNode {
    
    var title: String
    var anchor: ARAnchor?
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
    
    func addSphere(with radius: CGFloat, and color: UIColor) {
        let sphereNode = createSphereNode(with: radius, color: color)
        addChildNode(sphereNode)
    }
    
    func addNodeWithoutText(with radius: CGFloat, and color: UIColor, and text: String) {
        var image = UIImage(named: "start")
        let node = SCNNode(geometry: SCNPlane(width:5, height: 5))

        title = text
        if title.contains("arrived") {
            image = UIImage(named: "arrived")!
        } else if title.contains("left") {
            image = UIImage(named: "turnleft")!
        } else if title.contains("right") {
            image = UIImage(named: "turnright")!
        } else if title.contains("head") {
            image = UIImage(named: "straightahead")!
        }
        
        node.geometry?.firstMaterial?.diffuse.contents = image
        addChildNode(node)
    }
    
    func addNode(with radius: CGFloat, and color: UIColor, and text: String) {
//      let sphereNode = createSphereNode(with: radius, color: color)
        var image:UIImage? = UIImage(named: "start")
        let node = SCNNode(geometry: SCNPlane(width:5, height: 5))

        let newText = SCNText(string: title, extrusionDepth: 0.05)
        
        title = text
        if title.contains("arrived") {
            image = UIImage(named: "arrived")
        } else if title.contains("left") {
            image = UIImage(named: "turnleft")
        } else if title.contains("right") {
            image = UIImage(named: "turnright")
        } else if title.contains("head") {
            image = UIImage(named: "straightahead")
        }
        
        node.geometry?.firstMaterial?.diffuse.contents = image
        newText.font = UIFont (name: "AvenirNext-Medium", size: 9)
        newText.firstMaterial?.diffuse.contents = UIColor.red
        let _textNode = SCNNode(geometry: newText)
        node.addChildNode(_textNode)
        addChildNode(node)
    }
}

