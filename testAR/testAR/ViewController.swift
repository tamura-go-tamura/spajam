//
//  ViewController.swift
//  testAR
//
//  Created by scsendai-000 on 2020/10/17.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
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
        
        // 特徴点を描画
         sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

         // ライトの追加
         sceneView.autoenablesDefaultLighting = true;

         // 平面を検出
         let configuration = ARWorldTrackingConfiguration()
         configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
         }

         // 球を追加する
    func addSphere(hitResult: ARHitTestResult) {
         // ノードの生成
         let spherelNode = SCNNode()

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

         // 検出したアンカーに対応するノードに子ノードとして持たせる
         node.addChildNode(planeNode)
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
         }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event:
    UIEvent?) {
     // 最初にタップした座標を取り出す
     guard let touch = touches.first else {return}

     // スクリーン座標に変換する
     let touchPos = touch.location(in: sceneView)
        print(touchPos)

     // 検出した平面との当たり判定
     let hitTestResult = sceneView.hitTest(touchPos, types:.existingPlane)
     print(hitTestResult)
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

