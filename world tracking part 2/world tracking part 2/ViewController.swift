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
        let node = SCNNode() // node = position in space. no size, shape, or color
        
        // create path to create a custom shape
        // can use software to upload svg files to convert to a bezierpath 
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0)) // sets start point of path to the node set later
        path.addLine(to: CGPoint(x:0, y:0.2)) // add line from start point and move 0.2 up
        path.addLine(to: CGPoint(x:0.2, y:0.3)) // add line from start point and move 0.2 right and 0.3 up
        path.addLine(to: CGPoint(x:0.4, y:0.2)) // add line from start point and move 0.3 right and 0.2 up
        path.addLine(to: CGPoint(x:0.4, y:0)) // add line from start point and move 0.3 right
        let shape = SCNShape(path: path, extrusionDepth: 0.2) // extrudes path by 0.2
        node.geometry = shape
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        
        node.position = SCNVector3(0,0,-0.2)
        self.sceneView.scene.rootNode.addChildNode(node)
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
    
}

