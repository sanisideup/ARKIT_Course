//
//  ViewController.swift
//  whack_a_jelly
//
//  Created by Sani Djaya on 1/29/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        
        // trigger to identify that the sceneView was tapped
        // when tapGestureRecognizer is identified it runs the function handleTap
        let tapGestureReocgnizer = UITapGestureRecognizer(target:self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureReocgnizer)
 
    }

    @IBAction func play(_ sender: Any) {
        self.addNode()
        self.play.isEnabled = false
    }
    
    @IBAction func reset(_ sender: Any) {
        self.play.isEnabled = true
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "JellyFish", recursively: false)
        jellyFishNode!.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) { // sender: UITapGestureRecognizer sends information about the tap
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates ) // gets the the information about what you hit
        
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            let results = hitTest.first!
            
            // check if an animation is currently running to prevent animation to occur while one is occuring
            if results.node.animationKeys.isEmpty {
                self.animateNode(node: results.node)
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position // presentation represents the current position of node
        spin.toValue = SCNVector3(0,node.presentation.position.y + 0.5,0) // move to a point 1 meter above the current position
        spin.duration = 2 // set duration in secconds
//        spin.repeatCount = 3 // set how many times to repeat animation
//        spin.autoreverses = true // undo animation back to original position
        node.addAnimation(spin, forKey: "position") // triger annimation
        
        node.runAction(SCNAction.fadeOpacity(to: 0, duration: 1))
        node.runAction(SCNAction.sequence([SCNAction.wait(duration: 1),
                                           SCNAction.removeFromParentNode()]))


        
    }
}

