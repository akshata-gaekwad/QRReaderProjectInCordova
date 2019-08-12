//
//  ViewController.swift
//  ARKitDemoApp
//
//  Created by Christopher Webb-Orenstein on 8/27/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
     var type: ControllerType = .nav
     var delegate: NavigationViewControllerDelegate?
     var locationData: LocationData!
     var annotationColor = UIColor.blue
     var updateNodes: Bool = false
     var anchors: [ARAnchor] = []
     var nodes: [BaseNode] = []
    var steps: [MKRoute.Step] = []
     var locationService = LocationService()
     internal var annotations: [POIAnnotation] = []
     internal var startingLocation: CLLocation!
     var destinationLocation: CLLocationCoordinate2D!
     var locations: [CLLocation] = []
     var currentLegs: [[CLLocationCoordinate2D]] = []
     var updatedLocations: [CLLocation] = []
     let configuration = ARWorldTrackingConfiguration()
     var done: Bool = false
     var setpInstructions = ""
    
   weak var delegate2: ControllerCoordinatorDelegate?
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate2?.transitionCoordinator(type: .start)
    }
    
     var locationUpdates: Int = 0 {
        didSet {
            if locationUpdates >= 4 {
                updateNodes = false
            }
        }
    }
    
    var mapView = MKMapView()
    let sceneView = ARSCNView()
    
    @objc func backAction() -> Void {
    self.dismiss(animated: true, completion: nil)
}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backbutton = UIButton(type: .custom)
        backbutton.frame = CGRect(x: 5, y: 20, width: 45, height: 40)
        backbutton.setImage(UIImage(named: "back-button"), for: .normal) // Image can be downloaded from here below link
        //        backbutton.setTitle("Back", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal) // You can change the TitleColor
        backbutton.addTarget(self, action: #selector(ViewController.backAction), for: .touchUpInside)
        self.sceneView.addSubview(backbutton)
        
//        let backbutton = UIButton(type: .custom)
//        backbutton.setImage(UIImage(named: "BackButton.png"), for: UIControlState.normal) // Image can be downloaded from here below link
//        backbutton.setTitle("Back", for: UIControlState.normal)
//        backbutton.setTitleColor(backbutton.tintColor, for: UIControlState.normal) // You can change the TitleColor
//        backbutton.addTarget(self, action: #selector(ViewController.backAction), for:UIControlEvents.touchUpInside)
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
//        self.mapView = MKMapView(frame: CGRect(0,0,self.view.frame.size.width , self.view.frame.size.height))
        let SizeOfScreen: CGRect = UIScreen.main.bounds
        let HeightOfScreen = SizeOfScreen.height
        let WidthOfScreen = SizeOfScreen.width
        self.sceneView.frame = CGRect(x: 0, y: 0, width: WidthOfScreen, height: HeightOfScreen)
        self.view.addSubview(self.sceneView)
        
        mapView.delegate = self
        setupScene()
        setupLocationService()
        setupNavigation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateNodes = true
            if self.updatedLocations.count > 0 {
                self.startingLocation = CLLocation.bestLocationEstimate(locations: self.updatedLocations)
                if (self.startingLocation != nil && self.mapView.annotations.count == 0) && self.done == true {
                    DispatchQueue.main.async {
//                        self.centerMapInInitialCoordinates()
                        self.showPointsOfInterestInMap(currentLegs: self.currentLegs)
                        self.addAnnotations()
                        self.addAnchors(steps: self.steps)
                    }
                }
            }
        }

    }
}

extension ViewController: Controller {
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        delegate?.reset()
    }
    
     func setupLocationService() {
        locationService = LocationService()
        locationService.delegate = self
    }
    
     func setupNavigation() {
        if locationData != nil {
            steps.append(contentsOf: locationData.steps)
            currentLegs.append(contentsOf: locationData.legs)
            let coordinates = currentLegs.flatMap { $0 }
            locations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
            annotations.append(contentsOf: annotations)
            destinationLocation = locationData.destinationLocation.coordinate
        }
        done = true
    }
    
     func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        navigationController?.setNavigationBarHidden(true, animated: false)
        runSession()
    }
}

extension ViewController: MessagePresenting {
    
    // Set session configuration with compass and gravity 
    
    func runSession() {
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // Render nodes when user touches screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
     func showPointsOfInterestInMap(currentLegs: [[CLLocationCoordinate2D]]) {
        for leg in currentLegs {
            for item in leg {
                let poi = POIAnnotation(coordinate: item, name: String(describing:item))
                self.annotations.append(poi)
                self.mapView.addAnnotation(poi)
            }
        }
    }
    
     func addAnnotations() {
        annotations.forEach { annotation in
//            guard let map = mapView else { return }
            DispatchQueue.main.async {
                if let title = annotation.title, title.hasPrefix("N") {
                    self.annotationColor = .green
                } else {
                    self.annotationColor = .blue
                }
                self.mapView.addAnnotation(annotation)
                self.mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 0.2))
            }
        }
    }
    
     func updateNodePosition() {
        if updateNodes {
            locationUpdates += 1
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            if updatedLocations.count > 0 {
                startingLocation = CLLocation.bestLocationEstimate(locations: updatedLocations)
                for baseNode in nodes {
                    let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: baseNode.location)
                    let position = SCNVector3.positionFromTransform(translation)
                    let distance = baseNode.location.distance(from: startingLocation)
                    DispatchQueue.main.async {
                        let scale = 100 / Float(distance)
                        baseNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                        baseNode.anchor = ARAnchor(transform: translation)
                        baseNode.position = position
                    }
                }
            }
            SCNTransaction.commit()
        }
    }
    
    // For navigation route step add sphere node
    
    @nonobjc func addSphere(for step: MKRoute.Step) {
        let stepLocation = step.getLocation()
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: stepLocation)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: step.instructions, location: stepLocation)
        anchors.append(stepAnchor)
        sphere.addNode(with: 0.3, and: .green, and: step.instructions)
        setpInstructions = step.instructions
        sphere.location = stepLocation
        sphere.anchor = stepAnchor
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        nodes.append(sphere)
    }
    
    // For intermediary locations - CLLocation - add sphere
    
    @nonobjc func addSphere(for location: CLLocation) {
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: location)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: "Title", location: location)
        
//        if setpInstructions == ""{
            sphere.addSphere(with: 0.25, and: .yellow)
//        }else{
//            sphere.addNodeWithoutText(with: 0.3, and: .green, and: setpInstructions)
//        }
       
        anchors.append(stepAnchor)
        sphere.location = location
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        sphere.anchor = stepAnchor
        nodes.append(sphere)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        presentMessage(title: "Error", message: "Session Interuption")
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            print("ready")
        case .notAvailable:
            print("wait")
        case .limited(let reason):
            print("limited tracking state: \(reason)")
        }
    }
}

extension ViewController: LocationServiceDelegate {
    
    func trackingLocation(for currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 65.0 {
            updatedLocations.append(currentLocation)
            updateNodePosition()
        }
    }
    
    func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
            renderer.strokeColor = annotationColor
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Welcome to \(String(describing: title))", message: "You've selected \(String(describing: title))", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addAnchors(steps: [MKRoute.Step]) {
        guard startingLocation != nil && steps.count > 0 else { return }
        for step in steps { addSphere(for: step) }
        for location in locations { addSphere(for: location) }
    }
    
}

