//
//  ViewController.swift
//  world tracking
//
//  Created by Sani Djaya on 1/20/20.
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
    
    // function to place node on a random spot in the view in relation to rootNode
    func placeNode (nodeName: SCNNode, nodeColor: Any) {
        nodeName.geometry?.firstMaterial?.diffuse.contents = nodeColor // set whole node color
        nodeName.geometry?.firstMaterial?.specular.contents = UIColor.white // light reflecting off the surface
        
        // randomizes the position between -1 and 1 meter for (x,y,z)
        let x = randomNumbers(firstNum: -1, secondNum: 1)
        let y = randomNumbers(firstNum: -1, secondNum: 1)
        let z = randomNumbers(firstNum: -1, secondNum: 1)
        
        nodeName.position = SCNVector3(x,y,z) // set position of node in relation to rootNode in meters (x,y,z)
        
        self.sceneView.scene.rootNode.addChildNode(nodeName) // places node on to rootNode
    }

    // create red boxes
    @IBAction func Add(_ sender: Any) {
        let node = SCNNode() // node = position in space. no size, shape, or color
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius:0.03) // 10 cm^3 cube. to create a circle set width = height = length and divide hieght by 2
        placeNode(nodeName: node, nodeColor: UIColor.red)
    }
    
    // create blue capsules
    @IBAction func AddCapsule(_ sender: Any) {
        let node = SCNNode()
        node.geometry = SCNCapsule(capRadius: 0.05, height: 0.2)
        placeNode(nodeName: node, nodeColor: UIColor.blue)
    }
    
    
    @IBAction func AddCone(_ sender: Any) {
        let node = SCNNode()
        node.geometry = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.1)
        placeNode(nodeName: node, nodeColor: UIColor.green)
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
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

