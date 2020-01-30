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
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // define planets
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        sun.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Sun")
        sun.position = SCNVector3(0,0,-1)
        
        let earth = planet(geometry: SCNSphere(radius: 0.2), diffuse: UIImage(named: "EarthDay")!, specular: UIImage(named: "EarthSpecular"), emission: UIImage(named: "EarthClouds")!, normal: UIImage(named: "EarthNormal")!, position: SCNVector3(2,0,0))
        let moon = planet(geometry: SCNSphere(radius: 0.04), diffuse: UIImage(named: "Moon")!, specular: nil, emission: nil, normal: nil, position: SCNVector3(0,0,0.3))
        
        let venus = planet(geometry: SCNSphere(radius: 0.1), diffuse: UIImage(named: "VenusSurface")!, specular: nil, emission: UIImage(named: "VenusAtmosphere")!, normal: nil, position: SCNVector3(0.65,0,0))
        
        // define nodes to be used for orbit rotation
        let earthOrbit = SCNNode()
        let moonOrbit = SCNNode()
        let venusOrbit = SCNNode()
        earthOrbit.position = SCNVector3(0,0,-1)
        moonOrbit.position = SCNVector3(2,0,0)
        venusOrbit.position = SCNVector3(0,0,-1)

        
        // place nodes
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(earthOrbit)
        self.sceneView.scene.rootNode.addChildNode(venusOrbit)
        earthOrbit.addChildNode(earth)
        earthOrbit.addChildNode(moonOrbit)
        moonOrbit.addChildNode(moon)
//        venusOrbit.addChildNode(venus)
        
        // planet/sun rotation actions
        let sunRotationAction = rotateForever(duration: 16)
        sun.runAction(sunRotationAction)
        
        let earthRotationAction = rotateForever(duration: 8)
        let moonRotationAction = rotateForever(duration: 8)
        earth.runAction(earthRotationAction)
        moon.runAction(moonRotationAction)
        
        let venusRotationAction = rotateForever(duration: 2)
        venus.runAction(venusRotationAction)
        
        // orbit actions
        let earthOrbitAction = rotateForever(duration: 20)
        let moonOrbitAction = rotateForever(duration: 2)
        earthOrbit.runAction(earthOrbitAction)
        moonOrbit.runAction(moonOrbitAction)
        
        let venusOrbitAction = rotateForever(duration: 10)
        venusOrbit.runAction(venusOrbitAction)

    }
    
    func planet(geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?, emission: UIImage?, normal: UIImage?, position: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: geometry)
        node.geometry?.firstMaterial?.diffuse.contents = diffuse // sets color/texture
        node.geometry?.firstMaterial?.specular.contents = specular// specular controls how light is reflected
        node.geometry?.firstMaterial?.emission.contents = emission // emission adds or 'emits' the texture to the geometry
        node.geometry?.firstMaterial?.normal.contents = normal // normal adds 3D detail to add mountains/ridges on the surface of the geometry
        node.position = position
        return node
    }
    
    // rotate forever function
    func rotateForever(duration: Int) -> SCNAction {
        let rotationAction = SCNAction.rotateBy(x: 0, y: 360.degreeToRadians, z: 0, duration: TimeInterval(duration))
        return SCNAction.repeatForever(rotationAction) // loop action forever
    }


}

// convert degrees to radians
extension Int {
    var degreeToRadians: CGFloat { return CGFloat(Double(self) * .pi/180) }
    
    
}
