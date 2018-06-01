//
//  GameViewController.swift
//  RobotGame
//
//  Created by CXY on 2017/6/20.
//  Copyright © 2017年 CXY. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

let ScnViewHeight = CGFloat(500)
let ScreenWidth = UIScreen.main.bounds.size.width

class GameViewController: UIViewController {
    
    lazy var scnView = SCNView.init(frame: CGRect(x:(ScreenWidth-ScnViewHeight)/2, y:0, width:ScnViewHeight, height:ScnViewHeight))
    // lights file name
    lazy var lightArray = ["Light1","Light2","Light3"]
    
    func rootNodeWithSceneName(_ sceneName: String) -> SCNNode {
        let src = "art.scnassets/" + sceneName + ".scn"
        let stageScene = SCNScene(named: src)!
        if let stageNode = stageScene.rootNode.childNode(withName: sceneName, recursively: false) {
            //            stageNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
            return stageNode
        }
        return SCNNode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // add stage
        let stageNode = rootNodeWithSceneName("Stage")
        stageNode.scale = SCNVector3Make(1, 1, 1)
        scene.rootNode.addChildNode(stageNode)
        
        //add camera
        let stageScene = SCNScene(named: "art.scnassets/Stage.scn")
        
        if let cameraNode = stageScene?.rootNode.childNode(withName: "CameraHandle", recursively: true) {
            scene.rootNode.addChildNode(cameraNode)
        }
        
        // lights effect nodes
        for lightName in lightArray {
            let lightNode = rootNodeWithSceneName(lightName)
            lightNode.name = lightName
            lightNode.position = SCNVector3Make(0, 0, 0)
            lightNode.isHidden = false   // default
            lightNode.scale = SCNVector3(x:1, y:1, z:1)
            scene.rootNode.addChildNode(lightNode)
        }
        
        
        // Add real light node
        let customlightNode = SCNNode()
        let light = SCNLight()
        light.shadowColor = UIColor.red
        light.type = .ambient
        customlightNode.light = light
        customlightNode.light?.color = UIColor.red
        customlightNode.name = "lightNode"
        customlightNode.position = SCNVector3Make(0, 375, 0)
        scene.rootNode.addChildNode(customlightNode)
        
        // add robot
        let meebot = rootNodeWithSceneName("Meebot")
        meebot.scale = SCNVector3Make(1.5, 1.5, 1.5)
        scene.rootNode.addChildNode(meebot)
        
        // add audience
        let audience = rootNodeWithSceneName("Audience")
        scene.rootNode.addChildNode(audience)
        
        // animate the 3d object
//        meebot.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView.scene = scene
        
        view.addSubview(scnView)
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.clear
        
        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
    
    }
    
    @IBAction func animate(_ sender: UIButton) {
        let path = Bundle.main.path(forResource: "happy", ofType: "plist")
        let arr = NSMutableArray(contentsOfFile: path!)
        if let tmp = arr {
            for item in tmp {
                if let dict = item as? Dictionary<String, Array<NSNumber>> {
                    for (key, value) in dict {
                        let k = key
                        let v = value
                        let duration_per_step = 1.0
//                        guard let angles = servoAngles[action] else { return }
//                        guard let actions = animations[action] else { return }
//
//                        let beats_per_step = beats ?? 0 > 0 ? beats! / Double(angles.count) : 1.0
//                        let duration_per_step = calibrate_step_duration(beats_per_step * 60 / Double(bpm) * timeScale)
//                        let duration_per_step = 5
                        
                        if let node = scnView.scene?.rootNode.childNode(withName: key, recursively: true) {
                            let move = SCNAction.move(to: SCNVector3(value[0].floatValue, value[1].floatValue, value[2].floatValue), duration: duration_per_step)
                            let rotate = SCNAction.rotateTo(x: CGFloat(value[3].doubleValue * Double.pi / 180) , y: CGFloat(value[4].doubleValue * Double.pi / 180), z: CGFloat(value[5].doubleValue * Double.pi / 180), duration: duration_per_step, usesShortestUnitArc: true)
                            node.removeAllActions()
                            node.runAction(SCNAction.group([move, rotate]))
                        }
                    }
                }
            }
        }
        
    }
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
