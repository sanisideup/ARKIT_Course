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
    }


    @IBAction func Add(_ sender: Any) {
        let node = SCNNode() // node = position in space. no size, shape, or color
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius:0)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red // set whole node color to red
        node.position = SCNVector3(0,0,-0.3) // set position of node in relation to rootNode in meters (x,y,z)
        
        self.sceneView.scene.rootNode.addChildNode(node) // places node on to rootNode
    }
}

