//
//  ViewController.swift
//  world tracking part 2
//
//  Created by Sani Djaya on 1/22/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    //tracks the phones position and orientation in relation to the world
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // run debug configurations
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                       ARSCNDebugOptions.showWorldOrigin]
        // showFeaturePoints = stores information about features in the world around you that it detects. remembers the feature and location
        // showWorldOrigin = shows origin location of phone when it starts up
        
        // runs configuration of ARWorldTracking
        self.sceneView.session.run(configuration)
        
        // create omnidirectional light source into the view
        self.sceneView.autoenablesDefaultLighting = true
    }

    @IBAction func add(_ sender: Any) {
        
//        let pyramid = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
//        pyramid.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//
//
//        pyramid.position = SCNVector3(0,0,-0.3)
//        pyramid.eulerAngles = SCNVector3(Float(90.degreeToRadians),(Float(90.degreeToRadians)),0)
//        self.sceneView.scene.rootNode.addChildNode(pyramid)
//
//        // rotating the parent node will cause other nodes to rotate with it
//        // since the cylinder is a child of a the pyramid, the cylinder will rotate as well
        
//        let cylinder = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.1))
//        cylinder.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        cylinder.position = SCNVector3(0,0,0.2)
//        pyramid.addChildNode(cylinder)
        
        let node = SCNNode() // node = position in space. no size, shape, or color
        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        node.geometry?.firstMaterial?.specular.contents = UIColor.white

        let x = randomNumbers(firstNum: -1, secondNum: 1)
        let y = randomNumbers(firstNum: -1, secondNum: 1)
        let z = randomNumbers(firstNum: -1, secondNum: 1)
        node.position = SCNVector3(x,y,z) // set position of node in relation to rootNode in meters (x,y,z)
        
        let xR = randomNumbers(firstNum: 0, secondNum: 360)
        let yR = randomNumbers(firstNum: 360, secondNum: 360)
        let zR = randomNumbers(firstNum: 360, secondNum: 360)
        node.eulerAngles = SCNVector3(xR,yR,zR)
        self.sceneView.scene.rootNode.addChildNode(node)

        let box = SCNNode()
        box.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        box.geometry?.firstMaterial?.specular.contents = UIColor.white
        box.position = SCNVector3(0,-0.05,0)
        node.addChildNode(box) // position rlative to the pyramid

        let door = SCNNode(geometry:SCNPlane(width: 0.03, height: 0.06))
        door.geometry?.firstMaterial?.diffuse.contents = UIColor.random
        door.position = SCNVector3(0,-0.02,0.052)
        box.addChildNode(door)
    }
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    func restartSession() {
        self.sceneView.session.pause() // stops keeping track of your position and orientation
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in // enumerating through all child nodes of rootNode
            node.removeFromParentNode() // removing the boxnode from parent node removes it from scene view
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors]) // forget old starting position and orientation and make a new one based on where you are
    }
    
    // gives you a random number in the range you give it
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(	UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
}

extension Int {
    var degreeToRadians: Double { return Double(self) * .pi/180 }
    

}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
