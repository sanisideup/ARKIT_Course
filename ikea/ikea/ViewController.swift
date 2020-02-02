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
    let itemsArray: [String] = ["cup", "vase", "bag", "table"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuraiton)
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
        cell?.backgroundColor = UIColor.green // set color selected as green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) { // gets triggered when you deselect a cell
        let cell = collectionView.cellForItem(at: indexPath) //
        cell?.backgroundColor = UIColor.blue // set color selected as green
    }
}

