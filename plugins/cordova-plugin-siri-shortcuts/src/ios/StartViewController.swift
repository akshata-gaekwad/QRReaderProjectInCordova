//
//  StartViewController.swift
//  ARKitDemoApp
//
//  Created by Christopher Webb-Orenstein on 9/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ARKit

final class StartViewController:UIViewController,  Controller {
    
     var places = [Place]()
     let locationManager = CLLocationManager()
    var startedLoadingPOIs = false
    let mapView: MKMapView! = nil
    
    var arViewController :ARViewController!
    var placeName:String!
    var infoText:String!
     var annotationColor = UIColor.blue
    internal var annotations: [POIAnnotation] = []
     var currentTripLegs: [[CLLocationCoordinate2D]] = []
    weak var delegate: StartViewControllerDelegate?
    var locationService: LocationService = LocationService()
    var navigationService: NavigationService = NavigationService()
    var type: ControllerType = .nav
     var locations: [CLLocation] = []
    var startingLocation: CLLocation!
    var press: UILongPressGestureRecognizer!
    var steps: [MKRoute.Step] = []
    var sliderValue = Float()
    var records = [[String:Any]]()
    var destinationLocation: CLLocationCoordinate2D! {
        didSet {
            setupNavigation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        SVProgressHUD.show()
//        self.setupData()
        self.locationmanagerInitilisation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.sliderValueChanged(_:)), name: NSNotification.Name(rawValue: "slidervaluechanged"), object: nil)
    }
    
    func locationmanagerInitilisation(){
        sliderValue = 0
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        locationService.delegate = self
        guard let locationManager = locationService.locationManager else { return }
        locationService.startUpdatingLocation(locationManager: locationManager)
        mapView.delegate = self
    }
    
    func showARViewController(){
        
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxDistance = 5000
        arViewController.maxVisibleAnnotations = 30
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
            
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
//        arViewController.setAnnotations(self.places)
        arViewController.uiOptions.debugEnabled = true
        arViewController.uiOptions.closeButtonEnabled = false
        
        present(self.arViewController, animated: true, completion: nil)
        
    }

    @objc func sliderValueChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let slideValue = dict["value"] as? Float{
                sliderValue = slideValue

                arViewController.dataSource = self
                
                if Double(sliderValue) * 1000 == 0.0 {
                    arViewController.maxDistance = 0.1
                }else{
                    arViewController.maxDistance = Double(sliderValue) * 1000
                }

                arViewController.maxVisibleAnnotations = 30
                arViewController.maxVerticalLevel = 5
                arViewController.headingSmoothingFactor = 0.05

                arViewController.trackingManager.userDistanceFilter = 25
                arViewController.trackingManager.reloadDistanceFilter = 75
                arViewController.uiOptions.debugEnabled = true
                arViewController.uiOptions.closeButtonEnabled = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil, userInfo: nil)
                
            }
        }
    }

//    func setupData(){
//
//        let params = [
//            "entityId": "MOBILE",
//            "cbsType": "null",
//            "deviceId": "9",
//            "statusId": "0",
//            "sessionId": "null",
//            "appId": "3",
//            "secretKeyType": "S",
//            "thirdPartyRefNo": "18909911565838879",
//            "otpLength": "4",
//            "actionId": "ENQUIRY",
//            "subActionId": "LOCATEUS",
//            "RRN": "1554113740334",
//            "deviceDbId": "19846",
//            "customerId": "9126",
//            "map": [
//                "MobileNo": "55616963",
//                "secretKey": "null",
//                "clientAppVer": "1.0.3",
//                "latitude": "19.1276549",
//                "dataType": "branch",
//                "thirdPartyRefNo": "18909911565838879",
//                "entityId": "MOBILE",
//                "deviceId": "9911565838879",
//                "cbsType": "TCS",
//                "mobileAppVersion": "1.0.3",
//                "longitute": "72.8754791",
//                "mobPlatform": "ios",
//                "prefered_Language": "en_US",
//                "user_Language": "en",
//            ]
//            ] as [String : Any]
//
//        Servermanager.sharedManager.getData(apiUrl: Api.AccountOverview , parameters: params) {(isSuccessful, users) in
//            if(isSuccessful == true){
//                guard let users = users else{
//                    return
//                }
//
//                print(users)
//                SVProgressHUD.dismiss()
//                if let set = users["set"] as! [String:Any]?{
//                     if let records = set["records"] as? [[String:Any]] {
//
//                        for data in records {
//                            print(data)
//                            let lat = (data["latitude"] as! NSString).doubleValue
//                            let lng = (data["longitute"]as! NSString).doubleValue
//                            let ref = (data["cust_address"]as! NSString)  as String
//                            let name = (data["branch_name"]as! NSString) as String
//                            let address = (data["cust_address"]as! NSString) as String
//                            self.getNodesDetails(latitude: Double(lat), longitude:  Double(lng), reference: ref, name: name, address: address)
//
//                        }
//
//                        if ARConfiguration.isSupported {
//                            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                                self.showARViewController()
//                            }
//                        } else {
//                            self.presentMessage(title: "Not Compatible", message: "ARKit is not compatible with this phone.")
//                            return
//                        }
//
//                    }
//                }
//            }
//        }
//    }

    // Gets directions from from MapKit directions API, when finished calculates intermediary locations
    
    private func setupNavigation() {
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            
            if self.destinationLocation != nil {
                self.navigationService.getDirections(destinationLocation: self.destinationLocation, request: MKDirections.Request()) { steps , error in
                    
                    if let error = error?.localizedDescription{
//                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Alert" , message: error, preferredStyle: UIAlertController.Style.alert)
                        let okayAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                        
                        })
                        alert.addAction(okayAction)
                        self.arViewController.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    for step in steps {
                        self.annotations.append(POIAnnotation(coordinate: step.getLocation().coordinate, name: "N " + step.instructions))
                    }
                    self.steps.append(contentsOf: steps)
                    group.leave()
                }
            }
            
            // All steps must be added before moving to next step
            group.wait()
            
            self.getLocationData()
        }
    }
    
    private func getLocationData() {
        
        for (index, step) in steps.enumerated() {
            setTripLegFromStep(step, and: index)
        }
        
        for leg in currentTripLegs {
            update(intermediary: leg)
        }
        
//        centerMapInInitialCoordinates()
//        showPointsOfInterestInMap(currentTripLegs: currentTripLegs)
//        addMapAnnotations()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: self.placeName , message: self.infoText, preferredStyle: UIAlertController.Style.alert)
            
            let arAction = UIAlertAction(title: "AR VIEW", style: .default, handler: { action in
                let destination = CLLocation(latitude: self.destinationLocation.latitude, longitude: self.destinationLocation.longitude)
                self.delegate?.startNavigation(with: self.annotations, for: destination, and: self.currentTripLegs, and: self.steps)
            })
            
            let mapViewAction = UIAlertAction(title: "MAP VIEW", style: .default, handler: { action in

//                let viewController:MapViewController = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//                viewController.destinationLocation = self.destinationLocation
//                viewController.placeName = self.placeName
//                viewController.infoText = self.infoText
//                self.arViewController.present(viewController, animated: true, completion: nil)
                
            })
            
            alert.addAction(arAction)
            alert.addAction(mapViewAction)
            self.arViewController.present(alert, animated: true, completion: nil)
        }
    
    }
    
    // Gets coordinates between two locations at set intervals
    private func setLeg(from previous: CLLocation, to next: CLLocation) -> [CLLocationCoordinate2D] {
        return CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previous, destinationLocation: next)
    }
    
    // Add POI dots to map
    private func showPointsOfInterestInMap(currentTripLegs: [[CLLocationCoordinate2D]]) {
        mapView.removeAnnotations(mapView.annotations)
        for tripLeg in currentTripLegs {
            for coordinate in tripLeg {
                let poi = POIAnnotation(coordinate: coordinate, name: String(describing: coordinate))
                mapView.addAnnotation(poi)
            }
        }
    }
    
    // Adds calculated distances to annotations and locations arrays
    private func update(intermediary locations: [CLLocationCoordinate2D]) {
        for intermediaryLocation in locations {
            annotations.append(POIAnnotation(coordinate: intermediaryLocation, name: String(describing:intermediaryLocation)))
            self.locations.append(CLLocation(latitude: intermediaryLocation.latitude, longitude: intermediaryLocation.longitude))
        }
    }
    
    // Determines whether leg is first leg or not and routes logic accordingly
    private func setTripLegFromStep(_ tripStep: MKRoute.Step, and index: Int) {
        if index > 0 {
            getTripLeg(for: index, and: tripStep)
        } else {
            getInitialLeg(for: tripStep)
        }
    }
    
    // Calculates intermediary coordinates for route step that is not first
    private func getTripLeg(for index: Int, and tripStep: MKRoute.Step) {
        let previousIndex = index - 1
        let previousStep = steps[previousIndex]
        let previousLocation = CLLocation(latitude: previousStep.polyline.coordinate.latitude, longitude: previousStep.polyline.coordinate.longitude)
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediarySteps = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previousLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediarySteps)
    }
    
    // Calculates intermediary coordinates for first route step
    private func getInitialLeg(for tripStep: MKRoute.Step) {
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediaries = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: startingLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediaries)
    }
    
    // Prefix N is just a way to grab step annotations, could definitely get refactored
    private func addMapAnnotations() {
        annotations.forEach { annotation in
            
            // Step annotations are green, intermediary are blue
            DispatchQueue.main.async {
                if let title = annotation.title, title.hasPrefix("N") {
                    self.annotationColor = .green
                } else {
                    self.annotationColor = .blue
                }
                self.mapView?.addAnnotation(annotation)
                self.mapView.addOverlay(MKCircle(center: annotation.coordinate, radius: 0.2))
            }
        }
    }
}

extension StartViewController: LocationServiceDelegate, MessagePresenting {
    
    // Once location is tracking - zoom in and center map
    func trackingLocation(for currentLocation: CLLocation) {
        startingLocation = currentLocation
    }
    
    // Don't fail silently
    func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
}

extension StartViewController: MKMapViewDelegate {
    
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
}


extension StartViewController: CLLocationManagerDelegate {
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    getNodesDetails(latitude: 19.1176, longitude: 72.8715, reference: "Ackruti", name: "Ackruti Star", address: "Rd Number 7, Kondivita, Andheri East, Mumbai, Maharashtra 400069  \n Mobile : 9321788809  \n Website : www.ackruti.com ")
                    getNodesDetails(latitude: 19.1267, longitude: 72.8767, reference: "Seepz", name: "Seepz Sez", address: "Bus Stop Ln, Santacruz Electronic Export Processing Zone, Andheri East, Mumbai, Maharashtra 400078 \n Mobile : 23445654376  \n Website : www.seepz.com")
                    getNodesDetails(latitude: 19.1185, longitude: 72.8737, reference: "Sun City", name: "Sun City", address: "Rd Number 16, Marol, Andheri East, Mumbai, Maharashtra 400093  \n Mobile : 8709345621  \n Website : www.suncity.com ")
                    getNodesDetails(latitude: 36.2048, longitude: 138.2529, reference: "Japan", name: "japan Laos", address: "East China Sea and the Philippine Sea in the south  \n Mobile : 8563846333  \n Website : www.japan.com ")
                }
            }
        }
    }
    
    func getNodesDetails(latitude:Double , longitude:Double , reference:String ,name:String , address:String )  {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let place = Place(location: location, reference: reference, name: name, address: address)
        self.places.append(place)
        let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension StartViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension StartViewController: AnnotationViewDelegate {
    
    func didTouch(annotationView: AnnotationView) {
//        SVProgressHUD.show(withStatus: "Fetching Direction")
        if let annotation = annotationView.annotation as? Place {
            annotation.phoneNumber = ""
            annotation.website = ""
            placeName = annotation.placeName
            infoText = annotation.infoText
            destinationLocation = CLLocationCoordinate2D(latitude: (annotation.location?.coordinate.latitude)!, longitude: (annotation.location?.coordinate.longitude)!)
        }
    }

}
