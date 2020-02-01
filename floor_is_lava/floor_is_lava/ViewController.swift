//
//  ViewController.swift
//  floor_is_lava
//
//  Created by Sani Djaya on 1/31/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal // detects horizontal surfaces
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self // set sceneView delegate to self so that the delegate function "renderer" can be run
        
        // Do any additional setup after loading the view.
    }
    
    func createLava(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let lava = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))) // set lava size equal to the size of the plane anchor
        lava.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Lava")
        lava.geometry?.firstMaterial?.isDoubleSided = true // makes the material double sided
        lava.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z) // set lava position equal to center of plane anchor 
        lava.eulerAngles = SCNVector3(-90.degreeToRadians,0,0)
        return lava
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) { // detects an achor point
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // detcts a plane and adds an anchor to the plane
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
        print("new flat surface detected, new ARPlaneAnchor added")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // if this succeeds then the phone will update the horizontal anchor
        node.enumerateChildNodes {(childnode, _) in
            childnode.removeFromParentNode()
        }
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // when phone catches an error and removes a horizontal anchor
        node.enumerateChildNodes {(childnode, _) in
            childnode.removeFromParentNode()
        }
    }
}

// convert degrees to radians
extension Int {
    var degreeToRadians: CGFloat { return CGFloat(Double(self) * .pi/180) }
}

