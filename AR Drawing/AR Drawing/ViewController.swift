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

    @IBOutlet weak var draw: UIButton!
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
    
    var i: Int = 0
    
    // gets triggered as long as something is getting rendered
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        
        // gets the orientation vector of pointOfView (col3 row1, col3 row2, col3 row3)
        // note that the orientation is based on the screen, so since we want to place a node behind the camera, we make the vector negative
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        
        // gets location vector of pointOfView (col4 row1, rol4 row2, col4 row3)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        
        let frontOfCamera = orientation + location // combines the two vectors to get a node infront of the camera
        
        // diconnect the code from the background thread and put into main thread
        DispatchQueue.main.async{
            
            // if draw is being pressed
            if self.draw.isHighlighted {
                
                // draw is being pressed, so create a sphere to "draw" lines
                let sphereNode = SCNNode(geometry: SCNSphere(radius:0.02))
                sphereNode.name = "drawing" + String(self.i)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                sphereNode.position = frontOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)

                
            } else {
                
                // create a pointer when the draw button is NOT being pressed to let the user know where they will be drawing
                let pointer = SCNNode(geometry: SCNSphere(radius:0.01))
                pointer.name = "pointer" // set name of this node to pointer
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
                pointer.position = frontOfCamera
                
                // the pointer is created every time the screen is rendered, so you need to delete it every time as well so that a trail of pointers are not left behind
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    
                    // delete node that has the name pointer
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                    
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
            }
        }
        
    }
    
    
    @IBAction func drawPressed(_ sender: Any) {
        self.i += 1
        print(String(self.i))
    }
    
    @IBAction func reset(_ sender: Any) {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _ ) in
            node.removeFromParentNode()
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        print("undo" + String(self.i))
        self.i -= 1
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
            
            // delete most recent drawing press
            if node.name == "drawing" + String(self.i) {
                node.removeFromParentNode()
            }
        })
    }
    
}

// function to combine 2 vectors together
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
