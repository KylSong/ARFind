//
//  ViewController.swift
//  ArHackthon
//
//  Created by Kyle Song on 2019-02-23.
//  Copyright © 2019 Kyle Song. All rights reserved.
//

//import SpriteKit

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    struct Vec: Codable{
        var x : Float
        var y : Float
        var z : Float
        var tag : String
        //var Nodebody : SCNNode
    }
    
    var isLocated = false;
    var ancCor = Vec(x: 0, y: 0, z: 0, tag: "") //Nodebody: SCNNode.init()
    var nodeArr : [Vec] = []
    var lookingNode = false
    
    let save = "locationnew6hvhbb.json"
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var X: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        //X.sendActions(for: .touchUpInside)
        moveHor(view: NodeView,dis: NodeView.frame.height)
//        self.NodeView.delegate = self
//        self.NodeView.dataSource = self
        NodeView.delegate = self
        NodeView.dataSource = self
    }
//////////////////
    //var lookingNode = false
    @IBAction func showNodeView(_ sender: Any) {
        let moveAmount = NodeView.frame.height
            if lookingNode{
                moveHor(view: NodeView,dis: moveAmount)
                lookingNode = false
            }else{
                moveHor(view: NodeView,dis: -moveAmount)
                lookingNode = true
            }
        NodeView.reloadData()
    }
    
    @IBOutlet var NodeView: UITableView!
    func moveHor(view: UIView, dis:CGFloat) {
        //view.center.y += 300
        UIView.animate(withDuration: 0.3,
                       delay: 00,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .allowAnimatedContent,
                       animations: {view.center.y += dis},
                       completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodeArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = nodeArr[indexPath.row].tag
        //cell.textLabel?.font = UIFont(name: "Menlo Regular", size: 0.2)
        cell.textLabel?.font = UIFont(name: "Menlo", size: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            let name = cell.textLabel?.text
            let node = sceneView.scene.rootNode.childNode(withName: name!, recursively: true)
            node!.removeFromParentNode()
            for i in 0..<nodeArr.count-1{
                if(nodeArr[i].tag == name){
                    nodeArr.remove(at: i)
                }
            }
            Storage.store(nodeArr, to: .documents, as: save)
            //nodeArr.remove(at: indexPath.row)
            print(name!)
            
            tableView.reloadData()

        }
    }
    

    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            nodeArr.remove(at: indexPath.row)
//            UserDefaults.standard.set(nodeArr, forKey: "toDoList")
//            tableView.reloadData()
//        }
//    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.row == 0 {
//            return false
//        }
//        return true
//    }
    
///////////////////
//    @IBAction func km() {
//        //self.kmSelf.translatesAutoresizingMaskIntoConstraints = true;
//
//        let moveAmount = KeyView.frame.height/5*4+1
//        if self.show{
//            moveVet(butt: self.kmSelf, xwid: KeyView.frame.width, cont:"Keyboard")
//            moveHor(view: self.KeyView, dis:moveAmount)
//            //self.kmSelf.setTitle("Keyboard", for: .normal)
//            show = false
//        }else{
//            moveVet(butt: self.kmSelf,xwid: KeyView.frame.width/2+1, cont:"Result")
//            moveHor(view: self.KeyView, dis:-moveAmount)
//            //self.kmSelf.setTitle("Result", for: .normal)
//            show = true
//        }
//        // label.text = act
//    }
/////////////////////
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        // Add image as anchor
        if let imageAnchor = anchor as? ARImageAnchor {
            isLocated = true
            let mat = SCNMatrix4.init(imageAnchor.transform)
            ancCor.x = mat.m41
            ancCor.y = mat.m42
            ancCor.z = mat.m43
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.8)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
        }
        if(isLocated){
            // Drawing all previous nodes when anchors are located.
            appendItems(ancCor, anchorNode: node.childNodes[0])
        }
        
        return node
    }
    
    func scanQRCode(){
        
    }
    
    func appendItems(_ ancList: Vec, anchorNode: SCNNode){
        if Storage.fileExists(save, in: .documents) {
            // we have messages to retrieve
            nodeArr  = Storage.retrieve(save, from: .documents, as: [Vec].self)
            for item in nodeArr {
                createBallToAnchor(node: anchorNode, x: item.x, y: item.y, z: item.z, s: item.tag)
            }
        }
    }

    func createBallToAnchor(node: SCNNode, x: Float, y: Float, z: Float, s: String){
        let position = SCNVector3Make(x, y, z)
        let ballShape = SCNSphere(radius: 0.01)
        let ballNode = SCNNode(geometry: ballShape)
        
        // tag part
        let ballTag = SCNText(string: s, extrusionDepth: 1)
        let tagNode = SCNNode(geometry: ballTag)
        tagNode.scale = SCNVector3Make(0.001, 0.001, 0.001);
        ballNode.addChildNode(tagNode)
        
        ballNode.position = position
        ballNode.name = s
        node.addChildNode(ballNode)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if(lookingNode){
//            lookingNode = false
//            return
//        }
        // Only accept new touch if all image anchors are located.
        if(!isLocated){return}
        guard let touch = touches.first else {return}
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
        // Save the relative position of all items.
        nodeArr.append(Vec(x: hitTransform.m41 - ancCor.x, y: hitTransform.m42 - ancCor.y, z: hitTransform.m43 - ancCor.z, tag: "Num: " + String(nodeArr.count)))
        
        Storage.store(nodeArr, to: .documents, as: save)

        createBall(x: hitTransform.m41, y: hitTransform.m42, z: hitTransform.m43, s: "Num: " + String(nodeArr.count))
    }
    
    func createBall(x: Float, y: Float, z: Float, s: String){
        let position = SCNVector3Make(x, y, z)
        
        let ballShape = SCNSphere(radius: 0.01)
        let ballNode = SCNNode(geometry: ballShape)
        
        let ballTag = SCNText(string: s, extrusionDepth: 1)
        let tagNode = SCNNode(geometry: ballTag)
        tagNode.scale = SCNVector3Make(0.001, 0.001, 0.001);
        
        ballNode.addChildNode(tagNode)
        ballNode.position = position
        ballNode.name = s
        
        
//        let ballTag = SCNText(string: "okokokokoko", extrusionDepth: 0.001)
//        let tagNode = SCNNode(geometry: ballTag)
//        tagNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
        //tagNode.position = position
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        //sceneView.scene.rootNode.addChildNode(tagNode)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentFrame = frame.camera.transform
        let x = frame.camera.transform.columns.3.x
        let y = frame.camera.transform.columns.3.y
        let z = frame.camera.transform.columns.3.z
        print( "camera transform :\(x),\(y),\(z)")
    }
}
