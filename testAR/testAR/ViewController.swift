//
//  ViewController.swift
//  testAR
//
//  Created by scsendai-000 on 2020/10/17.
//

import UIKit
import SceneKit
import ARKit

var collideCount: Int = 0

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
         }
    
    //鬼と衝突したらカウントアップ
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            let nodeA = contact.nodeA
            let nodeB = contact.nodeB
            if (nodeA.name == "mato" && nodeB.name == "tama") {
                collideCount += 1
                nodeA.removeFromParentNode()
            } else if (nodeB.name == "mato" && nodeA.name == "tama") {
                collideCount += 1
                nodeB.removeFromParentNode()
            }
        print(collideCount)
        }

         // 球を追加する
    func addSphere(hitResult: ARHitTestResult) {
         // ノードの生成
         let spherelNode = SCNNode()
        spherelNode.name = "tama"

         // Geometryと Transform の設定
         let sphereGeometry = SCNSphere(radius: 0.03);
         spherelNode.geometry = sphereGeometry
         spherelNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + 0.05,hitResult.worldTransform.columns.3.z)

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

        let targetPosCamera = SCNVector3Make(0, 0, -2)
        let target = camera.convertPosition(targetPosCamera, to: nil)
        
         // 上向きの力をかける
        spherelNode.physicsBody?.applyForce(SCNVector3(5*target.x,5*target.y,5*target.z),
        asImpulse: true)

         // ノードの追加
         sceneView.scene.rootNode.addChildNode(spherelNode)
        
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
        let node = SCNNode() // ノードを生成
        node.geometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0) // 一片が10cmのキューブ
        node.name = "mato"
        let material = SCNMaterial() // マテリアル（表面）を生成する
        // 表面の色は、ランダムで指定する
        node.geometry?.materials = [material] // 表面の情報をノードに適用

        node.position = SCNVector3(0, 0, -1.5) // ノードの位置は、原点から左右：0m 上下：0m　奥に50cmとする
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = 2
        node.physicsBody?.collisionBitMask = 1
        node.physicsBody?.contactTestBitMask = 1
        sceneView.scene.rootNode.addChildNode(node) // 生成したノードをシーンに追加する
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
     // 最初にタップした座標を取り出す
     guard let touch = touches.first else {return}

     // スクリーン座標に変換する
     let touchPos = touch.location(in: sceneView)

     // 検出した平面との当たり判定
     let hitTestResult = sceneView.hitTest(touchPos, types:.existingPlane)
     
     if !hitTestResult.isEmpty {
     if let hitResult = hitTestResult.first {
     // 平面とあたっていたら球を追加する
     addSphere(hitResult :hitResult)
     }
     }
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

