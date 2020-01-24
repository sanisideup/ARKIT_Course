//
//  ViewController.swift
//  AR Drawing
//
//  Created by Sani Djaya on 1/23/20.
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
        self.sceneView.showsStatistics = true // shows performance
        self.sceneView.session.run(configuration)
        
        self.sceneView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    // gets triggered as long as something is getting rendered
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        print("rendering")
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        
        // gets the orientation vector of pointOfView (col3 row1, col3 row2, col3 row3)
        // note that the orientation is based on the screen, so since we want to place a node behind the camera, we make the vector negative 
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        
        // gets location vector of pointOfView (col4 row1, rol4 row2, col4 row3)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        
        let frontOfCamera = orientation + location // combines the two vectors to get a node infront of the camera
        print(orientation.x, orientation.y, orientation.z)
    }

}


func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
