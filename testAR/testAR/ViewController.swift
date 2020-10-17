//
//  ViewController.swift
//  testAR
//
//  Created by scsendai-000 on 2020/10/17.
//

import UIKit
import SceneKit
import ARKit
// AVクラスをインポートする
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    
    //鬼にぶつけた回数
    public var collideCount: Int = 0
    public var CountLabel:UILabel!
    public var Title:UILabel!


    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Title = UILabel(frame: CGRect(x:0 ,y:80, width: Int(self.view.frame.width), height: 40))
        Title.text = "Majinko Mamemaki"
        Title.textAlignment = NSTextAlignment.center
        Title.textColor = UIColor.red
        Title.font = UIFont(name: "Copperplate-Bold", size: 30)
        self.view.addSubview(Title)
        CountLabel = UILabel(frame: CGRect(x:Int(self.view.frame.width)/2-100 ,y:120, width: 200, height: 45))
        CountLabel.text = String(collideCount) + "/5"
        CountLabel.textAlignment = NSTextAlignment.center
        CountLabel.font = UIFont.boldSystemFont(ofSize: 35.0)
        //CountLabel.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.6)
        CountLabel.textColor = UIColor.white
        self.view.addSubview(CountLabel)

        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        // 特徴点を描画
         sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

         // ライトの追加
         sceneView.autoenablesDefaultLighting = true;

         // 平面を検出
         let configuration = ARWorldTrackingConfiguration()
        //すべての平面を検出する
         configuration.planeDetection = [.horizontal, .vertical]
        
        sceneView.session.run(configuration)
        oniComing()
         }
    
    //鬼と衝突したらカウントアップ
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            let nodeA = contact.nodeA
            let nodeB = contact.nodeB
            if (nodeA.name == "oni" && nodeB.name == "tama") {
                collideCount += 1
                nodeA.removeFromParentNode()
            } else if (nodeB.name == "oni" && nodeA.name == "tama") {
                collideCount += 1
                nodeB.removeFromParentNode()
            }
        scorealert()
        oniComing()
        }

         // 球を追加する
    func addSphere() {
         // ノードの生成
        let boxNode = SCNNode()
        boxNode.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let scene = SCNScene(named: "art.scnassets/beans.scn")
        let spherelNode = (scene?.rootNode.childNode(withName: "Cube", recursively: false))!
        spherelNode.name = "tama"
        spherelNode.rotation = SCNVector4(1, 0, 0, 0.25 * Float.pi)
         // Geometryと Transform の設定

         // PhysicsBody の挙動設定
         spherelNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape:
        nil)
        
        // PhysicsBody のパラメータ設定
         spherelNode.physicsBody?.mass = 1.0
         spherelNode.physicsBody?.friction = 1.5
         spherelNode.physicsBody?.rollingFriction = 1.0
         spherelNode.physicsBody?.damping = 0.5
         spherelNode.physicsBody?.angularDamping = 0.5
         spherelNode.physicsBody?.isAffectedByGravity = true
         spherelNode.physicsBody?.categoryBitMask = 1
        
        
        guard let camera = sceneView.pointOfView else {
               return
            }
        spherelNode.position = camera.position

        let targetPosCamera = SCNVector3Make(0, 0, -3)
        let target = camera.convertPosition(targetPosCamera, to: nil)
        
         // 上向きの力をかける
        spherelNode.physicsBody?.applyForce(SCNVector3(5*target.x,5*target.y,5*target.z),
        asImpulse: true)

         // ノードの追加
         sceneView.scene.rootNode.addChildNode(spherelNode)
        
    }

    //アプリがらかれた時に誕生する！
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            // Create a session configur
        guard let camera = sceneView.pointOfView else {
            return
        }
        let boxNode = SCNNode()
        boxNode.geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        let scene = SCNScene(named: "art.scnassets/oni.scn")
        let rabbitNode = (scene?.rootNode.childNode(withName: "Cube", recursively: false))!
        let cameraPos = SCNVector3Make(0, 0, -1)
        let position = camera.convertPosition(cameraPos, to: nil)
        //boxNode.position = position
        rabbitNode.position = position
        rabbitNode.name = "oni"
        rabbitNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        rabbitNode.physicsBody?.isAffectedByGravity = false
        rabbitNode.physicsBody?.categoryBitMask = 2
        rabbitNode.physicsBody?.collisionBitMask = 1
        rabbitNode.physicsBody?.contactTestBitMask = 1
        sceneView.scene.rootNode.addChildNode(rabbitNode)
    }

    

          //平面が検出されたときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode,
        for anchor: ARAnchor) {
        
        
         guard let planeAnchor = anchor as? ARPlaneAnchor else
        {fatalError()}

         // ノード作成
         let planeNode = SCNNode()

         // ジオメトリの作成する
         let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
         height: CGFloat(planeAnchor.extent.z))
         geometry.materials.first?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)

         // ノードに Geometryと Transform を指定
         planeNode.geometry = geometry
         planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1,
        0, 0)
        
        planeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape:
       nil)
       
       // PhysicsBody のパラメータ設定
        planeNode.physicsBody?.mass = 1.0
        planeNode.physicsBody?.friction = 1.5
        planeNode.physicsBody?.rollingFriction = 1.0
        planeNode.physicsBody?.damping = 0.5
        planeNode.physicsBody?.angularDamping = 0.5
        planeNode.physicsBody?.isAffectedByGravity = false

         // 検出したアンカーに対応するノードに子ノードとして持たせる
         node.addChildNode(planeNode)
        
        ///ここ鬼にしてみよう
        oniComing()
    }

    //鬼を召喚する
    func oniComing(){
        let boxNode = SCNNode()
        boxNode.geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        let scene = SCNScene(named: "art.scnassets/oni.scn")
        let rabbitNode = (scene?.rootNode.childNode(withName: "Cube", recursively: false))!
        rabbitNode.name = "oni"

        rabbitNode.position = SCNVector3(Int.random(in: -3..<3), Int.random(in: -3..<3), Int.random(in: -3..<3)) // ノードの位置は、原点から左右：0m 上下：0m　奥に50cmとする
        rabbitNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        rabbitNode.physicsBody?.isAffectedByGravity = false
        rabbitNode.physicsBody?.categoryBitMask = 2
        rabbitNode.physicsBody?.collisionBitMask = 1
        rabbitNode.physicsBody?.contactTestBitMask = 1
        sceneView.scene.rootNode.addChildNode(rabbitNode) // 生成したノードをシーンに追加する
    }

         // 平面が更新されたときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node:
        SCNNode, for anchor: ARAnchor) {
         guard let planeAnchor = anchor as? ARPlaneAnchor else
            
         {fatalError()}
          guard let geometryPlaneNode = node.childNodes.first,
          let planeGeometory = geometryPlaneNode.geometry as?
         SCNPlane else {fatalError()}

          // ジオメトリをアップデートする
          planeGeometory.width = CGFloat(planeAnchor.extent.x)
          planeGeometory.height = CGFloat(planeAnchor.extent.z)
          geometryPlaneNode.simdPosition = float3(planeAnchor.center.x,0,planeAnchor.center.z)
            
          geometryPlaneNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometory,options: nil))
         }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event:
    UIEvent?) {
        addSphere()
     }
    
    func scorealert() -> Void {
            DispatchQueue.main.sync {
            if self.collideCount == 5{
                    let alert: UIAlertController = UIAlertController(title: "CLEAR", message: "おめでとうございます", preferredStyle:  UIAlertController.Style.alert)
                let confirmAction = UIAlertAction(title: "閉じる", style:UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(confirmAction)
                present(alert, animated: true, completion: nil)
                    collideCount = 0
                }
                CountLabel.text = String(collideCount) + "/5"
            }
    }
    

        
                                                
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}
