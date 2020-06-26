//
//  ARViewController.swift
//  G'aryshker
//
//  Created by Баубек on 3/9/20.
//  Copyright © 2020 BaubekZh. All rights reserved.
//

import UIKit
import AVKit
import SceneKit
import AVFoundation
import ARKit

//MARK: - ARViewController
public class ARViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Properties
    lazy var earthRadius: CGFloat = 1.5
    lazy var positionXConstant = cos(.pi * 0.25) * earthRadius

    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
    let fadeOutAction = SCNAction.fadeOut(duration: 0.5)

    lazy var videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "First Human in Space", ofType: "mov")!)
    lazy var videoPlayer = AVPlayer(url: videoURL)

    var workItem: DispatchWorkItem?
    
    let configuration = ARWorldTrackingConfiguration()
    lazy var sceneView = ARSCNView(frame: UIScreen.main.bounds)
    lazy var scene = SCNScene(named: "3DModels.scnassets/vostok-1/vostok-1.scn")!
    
    lazy var backgroundImageView = UIImageView(image: UIImage(named: "space"))

    lazy var welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome to G'aryshker"
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont(name: "Futura", size: 36)
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Please point the camera towards open space"
        lbl.textColor = .lightGray
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "Arial", size: 20)
        return lbl
    }()
    
    lazy var tapAnywhereToContinueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap anywhere to continue"
        lbl.textColor = .lightGray
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "Helvetica", size: 12)
        return lbl
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let be = UIBlurEffect(style: .dark)
        let bv = UIVisualEffectView(effect: be)
        bv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return bv
    }()
        
    lazy var spaceship: SCNNode = {
        var node = scene.rootNode.childNode(withName: "Vostok1_mast_cabSG1", recursively: false)!
        node.scale = SCNVector3(0.001, 0.001, 0.001)
        node.position = SCNVector3(positionXConstant, 0, -8 + positionXConstant)
        node.eulerAngles = SCNVector3(0, .pi * 0.25, 0)
        return node
    }()
    
    lazy var infoNode: SCNNode = {
        let node = SCNNode(geometry: infoText)
        node.position = SCNVector3(-1, 1, -5.5)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        node.pivotOnTopCenter()
        return node
    }()
    
    lazy var infoText: SCNText = {
        let text = SCNText()
        text.font = UIFont.systemFont(ofSize: 0.8)
        text.flatness = 0.1
        text.materials.first?.diffuse.contents = UIColor.white.cgColor
        text.isWrapped = true
        return text
    }()
    
    lazy var videoPlaneNode: SCNNode = {
        let node = SCNNode(geometry: videoPlane)
        node.position = SCNVector3(4, 0, -7.5)
        node.eulerAngles = SCNVector3(0, -CGFloat.pi / 12, 0)
        return node
    }()
    
    lazy var videoPlane: SCNPlane = {
        let plane = SCNPlane(width: 2.5, height: 1.875)
        plane.materials.first?.diffuse.contents = videoPlayer
        return plane
    }()
    
    lazy var earth: SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: earthRadius))
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "earth")
        node.position = SCNVector3(0, 0, -8)
        node.eulerAngles.z = Float(-60.degreesToRadians())
        node.eulerAngles.y = Float(-40.degreesToRadians())
        return node
    }()

    // MARK: - View Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        AudioPlayer.turnOnBacgkroundMusic()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(self.configuration)
        setupSceneView()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        removeAllAnimations()
        cancelWorkItem()
    }

    // MARK: - Layout
    func setupLayout() {
        addSubviews()
        makeMaskFalse()
        activateConstraints()
        addGestures()
    }
    
    func addSubviews() {
        view.addSubview(sceneView)
        sceneView.addSubview(backgroundImageView)
        backgroundImageView.addSubview(blurView)
        sceneView.addSubview(welcomeLabel)
        sceneView.addSubview(descriptionLabel)
        sceneView.addSubview(tapAnywhereToContinueLabel)
    }
    
    func makeMaskFalse() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        tapAnywhereToContinueLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blurView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor),
            blurView.topAnchor.constraint(equalTo: sceneView.topAnchor),
            
            welcomeLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            welcomeLabel.widthAnchor.constraint(equalTo: sceneView.widthAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: sceneView.centerYAnchor, constant: -4),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: sceneView.widthAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: sceneView.centerYAnchor, constant: 4),
            
            tapAnywhereToContinueLabel.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
            tapAnywhereToContinueLabel.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
            tapAnywhereToContinueLabel.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -20),
            
            backgroundImageView.topAnchor.constraint(equalTo: sceneView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor, multiplier: 2)
        ])
    }
    
    func addGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startTheFlight))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Scene
    func setupSceneView() {
        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene.background.contents = UIColor.black
    }
    
    func addChildNodes() {
        sceneView.scene.rootNode.addChildNode(earth)
        sceneView.scene.rootNode.addChildNode(infoNode)
        sceneView.scene.rootNode.addChildNode(videoPlaneNode)
    }

    func animateNodes() {
        animateEarth()
        animateSpaceship()
    }

    func animateEarth() {
        let rotationAction = SCNAction.rotate(by: 290.degreesToRadians(), around: SCNVector3(0, 1, 0), duration: 24)
        let waitAction = SCNAction.wait(duration: 89)
        earth.runAction(SCNAction.sequence([waitAction, rotationAction]))
    }

    func animateSpaceship() {
        let waitAction = SCNAction.wait(duration: 79)
        let scaleAction = SCNAction.scale(by: 20, duration: 10)
        let moveAction = SCNAction.move(to: SCNVector3(0, 0, -5), duration: 10)
        let rotationAction = SCNAction.rotate(by: -.pi * 0.75, around: SCNVector3(0, 1, 0), duration: 10)
        let moveInOrbitAction = SCNAction.wait(duration: 20)
        let decreaseScaleAction = SCNAction.scale(to: 0, duration: 10)
        let moveBackAction = SCNAction.move(to: SCNVector3(-positionXConstant + 0.2, 0, -8 + positionXConstant), duration: 10)
        let flyIntoOrbitAction = SCNAction.group([scaleAction, moveAction, rotationAction])
        let backToEarthAction = SCNAction.group([decreaseScaleAction, moveBackAction, rotationAction])
        let flyToSpaceAction = SCNAction.sequence([waitAction, flyIntoOrbitAction, moveInOrbitAction,  backToEarthAction])

        spaceship.runAction(flyToSpaceAction)
    }

    //MARK:- Actions
    func setupVideoPlayer() {
        videoPlayer.play()
        for index in ContentService.videoTimeIndeces.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + ContentService.videoTimeIndeces[index]) {
                if self.videoPlayer.isPlaying {
                    self.videoPlayer.pause()
                    self.videoPlaneNode.runAction(self.fadeOutAction)
                } else {
                    self.videoPlaneNode.runAction(self.fadeInAction)
                    self.videoPlayer.play()
                }
            }
        }
    }

    func performChangingInfoText() {
        for index in ContentService.infoTexts.indices {
            workItem = DispatchWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + ContentService.infoTimeIndeces[index]) {
                    self.infoText.string = ContentService.infoTexts[index]
                }
            }
            DispatchQueue.main.async(execute: workItem!)
        }
    }

    func removeAllAnimations() {
        for childNode in sceneView.scene.rootNode.childNodes {
            childNode.removeAllActions()
        }
    }
    
    func cancelWorkItem() {
        DispatchQueue.main.async {
            self.workItem?.cancel()
        }
    }
    
    @objc func startTheFlight() {
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 2) {
            for subview in [self.welcomeLabel, self.descriptionLabel, self.tapAnywhereToContinueLabel, self.blurView, self.backgroundImageView] {
                subview.alpha = 0
            }
            self.addChildNodes()
            self.animateNodes()
            self.performChangingInfoText()
            self.setupVideoPlayer()
        }
    }
}
