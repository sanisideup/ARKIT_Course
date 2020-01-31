//
//  ViewController.swift
//  whack_a_jelly
//
//  Created by Sani Djaya on 1/29/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {

    var timer = Each(1).seconds
    var timerStart = Each(1.2).seconds
    var countDown = 10
    var countStart = 4
    var score = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.play.isHidden = false
        self.resetButton.isHidden = true
        
        // trigger to identify that the sceneView was tapped
        // when tapGestureRecognizer is identified it runs the function handleTap
        let tapGestureReocgnizer = UITapGestureRecognizer(target:self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureReocgnizer)
 
    }

    @IBAction func play(_ sender: Any) {
        self.resetScore()
        self.startGame()
        self.play.isHidden = true
    }
    
    @IBAction func reset(_ sender: Any) {
        self.restartARSession()
        self.killJelly()
        self.countDown = 0
        self.countStart = 4
        self.timerLabel.text = String(countDown)
        self.play.isHidden = false
        self.resetButton.isHidden = true
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "JellyFish", recursively: false)
        jellyFishNode!.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),
                                             randomNumbers(firstNum: -0.3, secondNum: 0.3),
                                             randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) { // sender: UITapGestureRecognizer sends information about the tap
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates ) // gets the the information about what you hit
        
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            self.restoreTimer()
            self.incScore()
            self.addNode()
            let results = hitTest.first!.node
            
            // check if an animation is currently running to prevent animation to occur while one is occuring
            if results.animationKeys.isEmpty {
                SCNTransaction.begin()              // begins tracking the a transaction
                self.animateNode(node: results)
                SCNTransaction.completionBlock = {  // once animation between this line and .begin() completes define lines to be executed
                    results.removeFromParentNode()
                }
                SCNTransaction.commit()             // execute lines defined within the completionBlock
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
        
        node.runAction(SCNAction.fadeOpacity(to: 0, duration: 1)) // fade out

    }
    
    // gives you a random number in the range you give it
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        restoreTimer()
        self.timer.perform { () -> NextStep in
            print("countDown: " + String(self.countDown))
            self.countDown -= 1
            self.timerLabel.text = String(self.countDown)
            if self.countDown <= 0 {
                self.countDown = 0
                self.timerLabel.text = String(self.countDown)
                self.killJelly()
                self.resetButton.isHidden = false
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countDown = 10
        self.timerLabel.text = String(self.countDown)
    }
    
    func killJelly() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in // enumerate nodes and execute below lines
            self.fadeNode(node: node)
        }
    }
    
    
    
    func incScore() {
        self.score += 1
        self.scoreLabel.text = String(score)
    }
    
    func resetScore() {
        self.score = 0
        self.scoreLabel.text = String(score)
    }
    
    func restartARSession() {
        self.sceneView.session.pause() // stops keeping track of your position and orientation
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors]) // forget old starting position and orientation and make a new one based on where you are
    }
    
    func startGame() {
        let guide = SCNNode()
        guide.geometry = SCNText(string: "Whack\n\n     a\n\n  Jelly", extrusionDepth: 3)
        guide.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        guide.position = SCNVector3(-0.4,-1,-2.5)
        guide.scale = SCNVector3(0.02,0.02,0.02)
        self.sceneView.scene.rootNode.addChildNode(guide)
        self.fadeNode(node: guide)
        
        self.timerStart.perform { () -> NextStep in
            print("countStart: " + String(self.countStart))
            
            if self.countStart <= 3 {
                let count = SCNNode()
                count.geometry = SCNText(string: String(self.countStart), extrusionDepth: 3)
                count.position = SCNVector3(-0.1,-0.3,-1)
                count.scale = SCNVector3(0.02,0.02,0.02)
                self.sceneView.scene.rootNode.addChildNode(count)
                self.fadeNode(node: count)
                
                if self.countStart <= 0 {
                    self.countStart = 0
                    
                    count.geometry = SCNText(string: String("Begin!"), extrusionDepth: 3)
                    count.position = SCNVector3(-0.4,-0.3,-2)
                    self.sceneView.scene.rootNode.addChildNode(count)
                    self.fadeNode(node: count)
                    
                    self.setTimer()
                    self.addNode()

                    return .stop
                }
            }
            self.countStart -= 1
            return .continue
        }
    }
    
    func fadeNode(node: SCNNode) {
        node.runAction(SCNAction.move(by: SCNVector3(0,0.5,0), duration: 2))
        node.runAction(SCNAction.fadeOpacity(to: 0, duration: 1))
        node.runAction(SCNAction.sequence([SCNAction.wait(duration: 1),
                                            SCNAction.removeFromParentNode()]))
    }
}

