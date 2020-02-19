//
//  ViewController.swift
//  Vehicle
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
    
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let concrete = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))) // set Concrete size equal to the size of the plane anchor
        concrete.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Concrete")
        concrete.geometry?.firstMaterial?.isDoubleSided = true // makes the material double sided
        concrete.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z) // set concrete position equal to center of plane anchor
        concrete.eulerAngles = SCNVector3(-90.degreeToRadians,0,0)
        
        // apply static physics to concrete allowing it to interact with the box 
        let staticBody = SCNPhysicsBody.static()
        concrete.physicsBody = staticBody
        
        return concrete
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) { // detects an achor point
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // detcts a plane and adds an anchor to the plane
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("new flat surface detected, new ARPlaneAnchor added")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // if this succeeds then the phone will update the horizontal anchor
        node.enumerateChildNodes {(childnode, _) in
            childnode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?ARPlaneAnchor else {return} // when phone catches an error and removes a horizontal anchor
        node.enumerateChildNodes {(childnode, _) in
            childnode.removeFromParentNode()
        }
    }
    @IBAction func addCar(_ sender: Any) {
        
        // get current point of view of camera
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        // grab geometry "frame" and set as root node of carNode
        let scene = SCNScene(named:"Car-Scene.scn")
        let carNode = (scene?.rootNode.childNode(withName: "frame", recursively: false))!
        carNode.position = currentPositionOfCamera
        
        //apply gravity to box
        let body = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(node: carNode, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        carNode.physicsBody = body
        
        self.sceneView.scene.rootNode.addChildNode(carNode)
    }
}

// convert degrees to radians
extension Int {
    var degreeToRadians: CGFloat { return CGFloat(Double(self) * .pi/180) }
}

// function to combine 2 vectors together
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

