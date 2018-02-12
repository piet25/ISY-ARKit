//
//  ViewController.swift
//  ISYText
//
//  Created by mp on 09.02.18.
//  Copyright © 2018 mp. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var sceneNode = SCNNode()
    var sceneRendered = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Debug Infos
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] //, ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        /*
        let textGeometry = SCNText(string: "Hello World", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(0,0.1,-40)
        textNode.scale = SCNVector3(0.5,0.5,0.5)
        
        scene.rootNode.addChildNode(textNode)
        */
        // Default lighting
        sceneView.autoenablesDefaultLighting = true
        
        loadScene()
    }
    
    func loadScene() {
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        let childNodes = scene?.rootNode.childNodes
        for childNode in childNodes! {
            sceneNode.scale = SCNVector3(0.1, 0.1, 0.1)
            sceneNode.position = SCNVector3Zero
            sceneNode.addChildNode(childNode)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let gridImage = UIImage(named: "tron_grid")
        let showPlane = SCNMaterial()
        showPlane.diffuse.contents = gridImage
        showPlane.transparency = 0.9
        showPlane.isDoubleSided = true
        
        plane.materials = [showPlane]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, anchor.center.y, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }

    func createBoxNode(anchor: ARPlaneAnchor) -> SCNNode {
        let box = SCNBox()

        let showBox = SCNMaterial()
        showBox.diffuse.contents = UIColor.blue
        showBox.transparency = 0.7
        showBox.isDoubleSided = true
        
        box.materials = [showBox]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3Make(anchor.center.x, anchor.center.y, anchor.center.z)
        
        return boxNode
    }
    
    func createTextNode(text: String, anchor: ARPlaneAnchor) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.alignmentMode = kCAAlignmentCenter
        
        let showText = SCNMaterial()
        showText.diffuse.contents = UIColor.red
        showText.isDoubleSided = true
        
        textGeometry.materials = [showText]
        let textNode = SCNNode(geometry: textGeometry)
        textGeometry.font = UIFont.systemFont(ofSize: 1)
        textNode.position = SCNVector3Make(anchor.center.x, anchor.center.y, anchor.center.z)
        print("Positon", anchor.center.x, anchor.center.y, anchor.center.z)
        //textNode.position = SCNVector3Zero
        textNode.scale = SCNVector3Make(0.04, 0.04, 0.04)
        
       
        // Translate so that the text node can be seen
        let (min, max) = textGeometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x)/2, min.y, max.z + 3.8)
        
        /*
        // Always look at the camera
        let node = SCNNode()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        node.constraints = [billboardConstraint]
        
        node.addChildNode(textNode)
        */
        return textNode
    }


    // Override to create and configure nodes for anchors added to the view's session.

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlaneNode(anchor: planeAnchor)
        let textNode = createTextNode(text: "TestNode", anchor: planeAnchor)
        node.addChildNode(planeNode)
        
        if !sceneRendered {
            sceneRendered = true
        
        node.addChildNode(textNode)
        //node.addChildNode(sceneNode)
        }
    }
    
/*
    // When a detected plane is updated, make a new planeNode
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        let planeNode = createPlaneNode(anchor: planeAnchor)
        //let textNode = createTextNode(text: "TestNode", anchor: planeAnchor)
        
        
        node.addChildNode(planeNode)
        //node.addChildNode(textNode)
        //node.addChildNode(sceneNode)
    }
*/
    
    // When a detected plane is removed, remove the planeNode
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session Failed")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Session interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        sceneView.session.run(session.configuration!,
                              options: [.resetTracking,
                                        .removeExistingAnchors])
    }
 
}
 
