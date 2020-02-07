//
//  ViewController.swift
//  ikea
//
//  Created by Sani Djaya on 1/31/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var planeDetected: UILabel!
    let configuraiton = ARWorldTrackingConfiguration()
    let itemsArray: [String] = ["cup", "vase", "boxing", "table"]
    var selectedItem: String? // set as optional string to allow conditional below in func addItem
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuraiton.planeDetection = .horizontal // detect horizontal planes!
        self.sceneView.session.run(configuraiton)
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        self.registerGestureRecognizer()
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func registerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer) // when a tap gesture is recognized on sceneview the tapped function gets called
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        longPressGestureRecognizer.minimumPressDuration = 0.1 
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView   // add tap gesture recognizer to scene view
        let tapLocation = sender.location(in: sceneView) // get location of user tap location in the sceneview
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent) // checks if tapLocation is a plane identified (in this case horizontal plane)
        
        // if hitTest is not empty, then user touched identified horizontal plane
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
        } else {
            print("boo")
        }
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView // add pinch gesture recognizer to sceneview
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0) // define scale action that is based on how much you pinch the screen
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            if sender.state == .began {
                let rotate = SCNAction.rotateBy(x: 0, y: 360.degreeToRadians, z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotate)
                node.runAction(forever)
            } else if sender.state == .ended {
                node.removeAllActions()
            }
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem { // if selected item is not nil, then place selected item
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn") // place model with name from selectedItem (defined in itemsArray)
            let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false)
            let transform = hitTestResult.worldTransform // get transform matrix of hitTestResult
            let thirdCol = transform.columns.3 // get the third column of the transform matrix to get the position of the horizontal plane detected
            node?.position = SCNVector3(thirdCol.x,thirdCol.y,thirdCol.z)
            if selectedItem == "table" {
                self.centerPivot(for: node!)
            }
            self.sceneView.scene.rootNode.addChildNode(node!)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // returns how many cells to display in the collection view
        return itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell// returns a cell type based on the cell type identifiter
        cell.itemLabel.text = self.itemsArray[indexPath.row] // get the label of the array in itemsArray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //gets triggered when you select a certain cell
        let cell = collectionView.cellForItem(at: indexPath) //
        self.selectedItem = itemsArray[indexPath.row] // get name of selected item from items array
        cell?.backgroundColor = UIColor.green // set color selected as green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { // gets triggered when you deselect a cell
        let cell = collectionView.cellForItem(at: indexPath) //
        cell?.backgroundColor = UIColor.orange // set color unselected
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return} // check if ARPlaneAnchor is added, else exit function
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // after 3 seconds hide label
                self.planeDetected.isHidden = true
            }
        }
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2)
    }
}
    

// convert degrees to radians
extension Int {
    var degreeToRadians: CGFloat { return CGFloat(Double(self) * .pi/180) }
}
