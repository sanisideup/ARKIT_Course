//
//  ViewController.swift
//  planets
//
//  Created by Sani Djaya on 1/29/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let earth = SCNNode()
        earth.geometry = SCNSphere(radius: 0.2)
        earth.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "EarthDay")
        earth.position = SCNVector3(0,0,-0.4)
        self.sceneView.scene.rootNode.addChildNode(earth)
        
        let action = SCNAction.rotateBy(x: 0, y: 360.degreeToRadians, z: 0, duration: 8) // rotate earth along y axis for 8 seconds
        earth.runAction(action) // trigger for running the action set just above
    }


}

extension Int {
    var degreeToRadians: CGFloat { return CGFloat(Double(self) * .pi/180) }
    
    
}
