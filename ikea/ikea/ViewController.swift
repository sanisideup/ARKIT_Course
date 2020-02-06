//
//  ViewController.swift
//  ikea
//
//  Created by Sani Djaya on 1/31/20.
//  Copyright © 2020 Sani Djaya. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    let configuraiton = ARWorldTrackingConfiguration()
    let itemsArray: [String] = ["cup", "vase", "boxing", "table"]
    var selectedItem: String? // set as optional string to allow conditional below in func addItem
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuraiton.planeDetection = .horizontal // detect horizontal planes!
        self.sceneView.session.run(configuraiton)
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        self.registerGestureRecognizer()
        // Do any additional setup after loading the view.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func registerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer) // when a tap gesture is recognized on sceneview the tapped function gets called
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView   // we know that the sceneview sent is ARSCNView, so force type
        let tapLocation = sender.location(in: sceneView) // get location of user tap location in the sceneview
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent) // checks if tapLocation is a plane identified (in this case horizontal plane)
        
        // if true, then touched identified horizontal plane
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
        } else {
            print("boo")
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem { // if selected item is not nil, then place selected item
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn") // place model with name from selectedItem (defined in itemsArray)
            let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false)
            let transform = hitTestResult.worldTransform // get transform matrix of hitTestResult
            let thirdCol = transform.columns.3 // get the third column of the transform matrix to get the position of the horizontal plane detected
            node?.position = SCNVector3(thirdCol.x,thirdCol.y,thirdCol.z)
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
    
    
}

