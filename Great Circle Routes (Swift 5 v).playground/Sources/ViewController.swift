import Foundation
import PlaygroundSupport
import AVKit
import MapKit

public class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    let customView = UIView()
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 500, height: 400))
    var backView = UIView(frame: CGRect(x: 134, y: 312, width: 500, height: 400))
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var pageControl : UIPageControl = UIPageControl(frame:CGRect(x: 284, y: 715, width: 200, height: 50))
    var greenlandImageView: UIImageView!
    var globeImageView: UIImageView!
    
    let blurEffect = UIBlurEffect(style: .regular)
    var blurEffectView: UIVisualEffectView!
    
    var result: (Array<NSDictionary>)? = nil
    
    let mapView = MKMapView(frame: CGRect(x:0, y:0, width: 768, height:924))
    var airplane: MKPointAnnotation!
    var airplanePosition = 0
    
    var planeCamera: MKMapCamera!
    
    var geodesic: MKGeodesicPolyline!
    var airplaneDirection: CLLocationDirection!
    var annotationView = MKAnnotationView()
    var annotations = [MKAnnotation]()
    
    var shouldRun: Bool = false
    var followCamera: Bool = false
    
    var cameraButton = UIButton(type: .custom)
    var cameraLabel = UILabel()
    
    var planeButton = UIButton(type: .custom)
    var planeLabel = UILabel()
    
    var dismissButton = UIButton(type: .custom)
    
    var exampleButton = UIButton(type: .custom)
    var exampleView = UIView(frame: CGRect(x: 134, y: 312, width: 500, height: 400))
    
    var airportText1 = UITextField()
    var airportText2 = UITextField()
    var airportInput1: String?
    var airportInput2: String?
    var airportToSpeak: Airport?
    
    var toLabel = UILabel()
    
    var setAirportsButton = UIButton(type: .system)
    
    var player: AVAudioPlayer!
    
    let airportPin1 = MKPointAnnotation()
    let airportPin2 = MKPointAnnotation()
    
    var increment: Int!
    var points: UnsafeMutablePointer<MKMapPoint>!
    var halfwaypoint: Int!
    
    public override func loadView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.customView.bounds = CGRect(x: 0, y: 0, width: 768, height: 1024)
        self.customView.backgroundColor = UIColor(red: 0.973, green: 0.961, blue: 0.937, alpha: 1.0)
        self.view = self.customView
        
        self.mapView.delegate = self
        self.customView.addSubview(self.mapView)
        
        self.exampleButton.setImage(UIImage(named: "exampleButtonCorrect.png"), for: .normal)
        self.exampleButton.addTarget(self, action: #selector(presentExampleCodes), for: .touchUpInside)
        self.exampleButton.isEnabled = true
        self.exampleButton.frame = CGRect(x: 20, y: 936, width: 95, height: 70)
        
        self.cameraButton.setImage(UIImage(named: "airplane-camera-button.png"), for: .normal)
        self.cameraButton.setImage(UIImage(named: "airplane-camera-button-activated.png"), for: .selected)
        self.cameraButton.addTarget(self, action: #selector(pressCameraButton), for: .touchUpInside)
        self.cameraButton.isEnabled = false
        self.cameraButton.frame = CGRect(x: 685, y: 850, width: 40, height: 40)
        
        self.cameraLabel.text = "Follow Airplane"
        self.cameraLabel.font = .boldSystemFont(ofSize: 13)
        self.cameraLabel.textColor = .darkText
        self.cameraLabel.textAlignment = .center
        self.cameraLabel.frame = CGRect(x: 655, y: 885, width: 100, height: 25)
        
        self.planeButton.setImage(UIImage(named: "airplane-button.png"), for: .normal)
        self.planeButton.setImage(UIImage(named: "airplane-button-activated.png"), for: .selected)
        self.planeButton.addTarget(self, action: #selector(togglePlane), for: .touchUpInside)
        self.planeButton.isEnabled = false
        self.planeButton.frame = CGRect(x: 50, y: 850, width: 40, height: 40)
        
        self.planeLabel.text = "Airplane Disabled"
        self.planeLabel.font = .boldSystemFont(ofSize: 13)
        self.planeLabel.textColor = .darkText
        self.planeLabel.textAlignment = .center
        self.planeLabel.frame = CGRect(x: 10, y: 885, width: 125, height: 25)
        
        self.airportText1.borderStyle = .roundedRect
        self.airportText1.placeholder = "Enter 3-digit IATA Code"
        self.airportText1.autocapitalizationType = .allCharacters
        self.airportText1.autocorrectionType = .no
        self.airportText1.delegate = self
        self.airportText1.frame = CGRect(x: 129, y: 935, width: 210, height: 25)
        
        self.airportText2.borderStyle = .roundedRect
        self.airportText2.placeholder = "Enter 3-digit IATA Code"
        self.airportText2.autocapitalizationType = .allCharacters
        self.airportText2.autocorrectionType = .no
        self.airportText2.delegate = self
        self.airportText2.frame = CGRect(x: 429, y: 935, width: 210, height: 25)
        
        self.toLabel.text = "to"
        self.toLabel.font = .boldSystemFont(ofSize: 14)
        self.toLabel.textAlignment = .center
        self.toLabel.frame = CGRect(x: 359, y: 935, width: 50, height: 25)
        
        self.setAirportsButton.setTitle("Create Great Circle Route", for: .normal)
        self.setAirportsButton.setTitleColor(.white, for: .normal)
        self.setAirportsButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        self.setAirportsButton.titleLabel?.textAlignment = .center
        self.setAirportsButton.layer.cornerRadius = 10
        self.setAirportsButton.backgroundColor = UIColor(red: 0.251, green: 0.396, blue: 0.816, alpha: 1.0)
        self.setAirportsButton.addTarget(self, action: #selector(enplane), for: .touchUpInside)
        self.setAirportsButton.frame = CGRect(x: 234, y: 975, width: 300, height: 30)
        
        self.exampleView.backgroundColor = UIColor(red: 0.973, green: 0.961, blue: 0.937, alpha: 1.0)
        self.exampleView.alpha = 0
        self.exampleView.layer.shadowColor = UIColor.black.cgColor
        self.exampleView.layer.shadowOpacity = 0.75
        self.exampleView.layer.shadowOffset = .zero
        self.exampleView.layer.shadowRadius = 8
        self.exampleView.layer.masksToBounds = false
        self.exampleView.layer.cornerRadius = 10
        self.exampleView.addSubview(getExampleTextLabel())
        
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("Close", for: .normal)
        exitButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        exitButton.titleLabel?.textAlignment = .center
        exitButton.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        exitButton.center = CGPoint(x: 250, y: 370)
        exitButton.addTarget(self, action: #selector(dismissExample), for: .touchUpInside)
        self.exampleView.addSubview(exitButton)
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(didMoveMap(gestureRec:)))
        panRec.delegate = self
        
        self.mapView.addGestureRecognizer(panRec)
        self.mapView.addSubview(self.cameraButton)
        self.mapView.addSubview(self.cameraLabel)
        self.mapView.addSubview(self.planeButton)
        self.mapView.addSubview(self.planeLabel)
        self.customView.addSubview(self.airportText1)
        self.customView.addSubview(self.airportText2)
        self.customView.addSubview(self.toLabel)
        self.customView.addSubview(self.setAirportsButton)
        self.customView.addSubview(self.exampleButton)
        
        self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.customView.addSubview(self.blurEffectView)
        
        self.scrollView.delegate = self
        
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = .white
        self.customView.addSubview(pageControl)
        
        for index in 0..<3 {
            
            frame.origin.x = self.scrollView.frame.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            let subView = UIView(frame: frame)
            subView.backgroundColor = UIColor(red: 0.973, green: 0.961, blue: 0.937, alpha: 1.0)
            
            if index == 0 {
                subView.addSubview(getLabelOne())
                subView.addSubview(getNextLabel())
            } else if index == 1 {
                subView.addSubview(getLabelTwoPtOne())
                subView.addSubview(getLabelTwoPtTwo())
                self.greenlandImageView = UIImageView(image: #imageLiteral(resourceName: "greenlandWhy.png"))
                self.greenlandImageView.frame = CGRect(x: 0, y: 0, width: 94, height: 125)
                self.greenlandImageView.center = CGPoint(x: 443, y: 147)
                subView.addSubview(self.greenlandImageView)
                self.globeImageView = UIImageView(image: #imageLiteral(resourceName: "globeExample.png"))
                self.globeImageView.frame = CGRect(x: 0, y: 0, width: 140, height: 140)
                self.globeImageView.center = CGPoint(x: 393, y: 294)
                subView.addSubview(self.globeImageView)
                subView.addSubview(getNextLabel())
                
            } else {
                subView.addSubview(getLabelThree())
                self.dismissButton.setImage(UIImage(named: "dismissButton.png"), for: .normal)
                self.dismissButton.addTarget(self, action: #selector(dismissOnboarding), for: .touchUpInside)
                self.dismissButton.isEnabled = true
                self.dismissButton.frame = CGRect(x: 0, y: 0, width: 194, height: 37)
                self.dismissButton.center = CGPoint(x: 250, y: 350)
                subView.addSubview(self.dismissButton)
            }
            
            self.scrollView.addSubview(subView)
            
        }
        self.backView.backgroundColor = UIColor(red: 0.973, green: 0.961, blue: 0.937, alpha: 1.0)
        self.backView.layer.shadowColor = UIColor.black.cgColor
        self.backView.layer.shadowOpacity = 0.75
        self.backView.layer.shadowOffset = .zero
        self.backView.layer.shadowRadius = 8
        self.backView.layer.cornerRadius = 10
        self.backView.layer.masksToBounds = false
        
        self.customView.addSubview(self.backView)
        self.backView.addSubview(self.scrollView)
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 3, height: self.scrollView.frame.size.height)
        self.scrollView.layer.cornerRadius = 10
        self.scrollView.backgroundColor = UIColor(red: 0.973, green: 0.961, blue: 0.937, alpha: 1.0)
        self.scrollView.layer.masksToBounds = true
        self.pageControl.addTarget(self, action: #selector(changePage(sender:)), for: .valueChanged)
        
        // Preload the JSON file into an array of dictonaries.
        let path = Bundle.main.path(forResource: "airport-codes-final", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: [])
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: [])
        self.result = jsonResult as? Array<NSDictionary>
        
        let chipAnnotation = MKPointAnnotation()
        chipAnnotation.title = "Chip Beck"
        chipAnnotation.subtitle = "Do you know the way to San Jose? PIT doesn't!"
        chipAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.4958, longitude: -80.2413)
        self.mapView.addAnnotation(chipAnnotation)
        
        let wwdcAnnotation = MKPointAnnotation()
        wwdcAnnotation.title = "Dub dub"
        wwdcAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.3293, longitude: -121.8875)
        self.mapView.addAnnotation(wwdcAnnotation)
        
    }
    
    // Selector called functions
    
    @objc func presentExampleCodes() {
        
        self.blurEffectView.alpha = 0
        self.customView.addSubview(self.blurEffectView)
        self.exampleView.alpha = 0
        self.customView.addSubview(self.exampleView)
        
        UIView.animate(withDuration: 0.333, animations: {
            self.blurEffectView.alpha = 1.0
            self.exampleView.alpha = 1.0
        })
        
    }
    
    @objc func dismissExample() {
        UIView.animate(withDuration: 0.333, animations: {
            self.blurEffectView.alpha = 0.0
            self.exampleView.alpha = 0.0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
            self.backView.removeFromSuperview()
            self.pageControl.removeFromSuperview()
        }
    }
    
    @objc func dismissOnboarding() {
        
        UIView.animate(withDuration: 0.333, animations: {
            self.blurEffectView.alpha = 0.0
            self.backView.alpha = 0.0
            self.pageControl.alpha = 0.0
        }) { _ in
            self.blurEffectView.removeFromSuperview()
            self.backView.removeFromSuperview()
            self.pageControl.removeFromSuperview()
        }
        
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * self.scrollView.frame.size.width
        self.scrollView.setContentOffset(CGPoint(x: x, y :0), animated: true)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let size = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3, animations:  {
            var frame = self.view.frame
            frame.origin.y = -size
            self.view.frame = frame
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3, animations:  {
            var frame = self.view.frame
            frame.origin.y = 0.0
            self.view.frame = frame
        })
    }
    
    @objc func togglePlane() {
        self.planeButton.isSelected = !self.planeButton.isSelected
        if !self.planeButton.isSelected {
            deplane()
        } else {
            enplane()
        }
    }
    
    func deplane() {
        self.shouldRun = false
        self.followCamera = false
        self.cameraButton.isSelected = false
        self.cameraButton.isEnabled = false
        self.planeLabel.text = "Airplane Disabled"
        if airplane != nil {
            self.mapView.removeAnnotation(self.airplane)
            self.annotations = self.annotations.filter() { $0 !== self.airplane }
        }
    }
    
    @objc func enplane() {
        guard self.airportText1.text != nil && self.airportText2.text != nil else {
            let alertController = UIAlertController(title: "Error", message: "You must enter two valid and different IATA airport codes.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        self.airportText1.resignFirstResponder()
        self.airportText2.resignFirstResponder()
        
        // Remove past annotations and overlays if they exist.
        self.mapView.removeAnnotations(self.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        self.airplanePosition = 0
        self.createGCR(airport1: self.airportText1.text!.uppercased(), airport2: self.airportText2.text!.uppercased())
        
    }
    
    @objc func pressCameraButton() {
        self.cameraButton.isSelected = !self.cameraButton.isSelected
        if self.cameraButton.isSelected {
            self.followCamera = true
            self.mapView.setCamera(self.planeCamera, animated: true)
        } else {
            self.followCamera = false
        }
    }
    
    @objc func didMoveMap(gestureRec: UIGestureRecognizer) {
        if gestureRec.state == .began {
            self.followCamera = false
            self.cameraButton.isSelected = false
        }
    }
    
    
    /*
     The following method increments the plane's position and adjusts direction.
     It increments slowly to accommodate for the slowness of Xcode Playgrounds as it logs everything.
     */
    
    func updateAirplanePositionDirection() {
        
        guard self.shouldRun else {
            return
        }
        
        guard (airplanePosition + self.increment < self.geodesic.pointCount)
            else {
                self.airplane.coordinate = self.points[geodesic.pointCount-1].coordinate
                speakWithLocale(airport: airportToSpeak)
                return
        }
        
        if self.airplanePosition == increment * 2 {
            self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "airplane-takeoff", ofType: "mp3")!))
            self.player.prepareToPlay()
            self.player.play()
        }
        
        if (self.airplanePosition >= (self.halfwaypoint) - (self.increment / 2)) && (self.airplanePosition < (self.halfwaypoint) + (self.increment / 2)) {
            self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "seatbelt-ding", ofType: "mp3")!))
            self.player.prepareToPlay()
            self.player.play()
        }
        
        let previousPoint = self.points[self.airplanePosition]
        self.airplanePosition = self.airplanePosition + self.increment
        let nextPoint = self.points[self.airplanePosition]
        
        self.airplaneDirection = directionBetweenPoints(source: previousPoint, nextPoint)
        self.airplane.coordinate = nextPoint.coordinate
        
        if self.followCamera {
            self.cameraButton.isSelected = true
            self.planeCamera.centerCoordinate = self.airplane.coordinate
            self.mapView.setCamera(self.planeCamera, animated: true);
            
        }
        
        self.annotationView.transform = self.mapView.transform.rotated(by: CGFloat(degreesToRadians(degrees: self.airplaneDirection)))
        
        // Recursively call self on for UI animation
        // on different thread to help with performance.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            self.updateAirplanePositionDirection()
        })
        
    }
    
    func directionBetweenPoints(source: MKMapPoint, _ destination: MKMapPoint) -> CLLocationDirection {
        let x = destination.x - source.x
        let y = destination.y - source.y
        
        return radiansToDegrees(radians: atan2(y, x)).truncatingRemainder(dividingBy: 360) + 90
    }
    
    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
    // Creates "great circle route" (GCR) polyline
    func createGCR(airport1: String, airport2: String) {
        guard (airport1 != "" || airport2 != "" || airport1 != airport2) else {
            let alertController = UIAlertController(title: "Error", message: "Enter two valid and different IATA airport codes.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let point1: Airport? = findAirport(airport: airport1)
        let point2: Airport? = findAirport(airport: airport2)
        guard (point1 != nil && point2 != nil) else {
            let alertController = UIAlertController(title: "Error", message: "Invalid IATA airport code(s).", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
            
        self.airportInput1 = point1?.code
        self.airportInput2 = point2?.code
            
        self.airportToSpeak = point2
        // Separates the longitude and latitude into two seperate Doubles through the split method,
        // separating at ","
        
        let point1Long = Double(point1!.coordinates.split(separator: ",")[0])!
        let point1Lat = Double(point1!.coordinates.split(separator: ",")[1])!
        let point2Long = Double(point2!.coordinates.split(separator: ",")[0])!
        let point2Lat = Double(point2!.coordinates.split(separator: ",")[1])!
        let cll1 = CLLocation(latitude: point1Lat, longitude: point1Long)
            
        let cll2 = CLLocation(latitude: point2Lat, longitude: point2Long)
        
        // Creates MKGeodesicPolyline -- or the GCR -- from the two airport coordinates.
        self.geodesic = MKGeodesicPolyline(coordinates: [cll1.coordinate, cll2.coordinate], count: 2)
        self.mapView.addOverlay(geodesic)
            
        let annotation = MKPointAnnotation()
        annotation.title = (airport1 + " to " + airport2)
        annotation.subtitle = "Airplane"
        self.mapView.addAnnotation(annotation)
        self.airplane = annotation
            
        airportPin1.subtitle = "Origin"
        airportPin1.title = (airport1 + ": " + point1!.name)
        airportPin2.subtitle = "Destinaton"
        airportPin2.title = (airport2 + ": " + point2!.name)
        airportPin1.coordinate = cll1.coordinate
        airportPin2.coordinate = cll2.coordinate
        self.mapView.addAnnotations([airportPin1, airportPin2])
        self.annotations.append(airportPin1)
        self.annotations.append(airportPin2)
        self.annotations.append(self.airplane)
        
        self.planeCamera = MKMapCamera(lookingAtCenter: cll1.coordinate, fromEyeCoordinate: cll1.coordinate, eyeAltitude: 6500000)
        mapView.setCamera(self.planeCamera, animated: true)
       
        self.points = geodesic.points()
        self.halfwaypoint = geodesic.pointCount / 2
        
        if geodesic.pointCount > 9900 {
            increment = geodesic.pointCount / 46
        } else if geodesic.pointCount > 5400 {
            increment = geodesic.pointCount / 32
        } else if geodesic.pointCount > 2700 {
            increment = geodesic.pointCount / 28
        } else if geodesic.pointCount > 1500 {
            increment = 40
        } else if geodesic.pointCount > 500 {
            increment = 30
        } else {
            increment = 20
        }
            
        self.shouldRun = true
        self.followCamera = true
        self.planeButton.isSelected = true
        self.cameraButton.isSelected = true
        self.planeButton.isEnabled = true
        self.cameraButton.isEnabled = true
        self.planeLabel.text = "Airplane Enabled"
        self.airplanePosition = 0
        self.updateAirplanePositionDirection()
        
    }
    
    func findAirport(airport: String) -> Airport? {
        
        // Searches JSON database for the entered codes. Returns Airport object or nil.
        for code in result! {
            if code["iata_code"] as! String == airport {
                let airportObj = Airport(code: airport, coordinates: code["coordinates"] as! String, name: code["name"] as! String, country: code["iso_country"] as! String)
                return airportObj
            }
        }
        return nil //Returns nil if the airport doesn't exist at that code.
    }
    
    // Delegate functions
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 5.0
        renderer.alpha = 0.75
        renderer.strokeColor = UIColor(red: 0.753, green: 0.624, blue: 0.953, alpha: 0.75)
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoView: MKPinAnnotationView?
        let annoView2: MKAnnotationView?
        if annotation.title! == "Dub dub" {
            annoView2 = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.title!!) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!)
            annoView2?.image = #imageLiteral(resourceName: "wwdc-text-small.png")
            annoView2?.canShowCallout = false
            annoView = nil
        }
        else if annotation.title! == "Chip Beck" {
            annoView2 = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.title!!) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!)
            annoView2?.image = #imageLiteral(resourceName: "rbSprite.png")
            annoView2?.canShowCallout = true
            annoView = nil
        }
        else if annotation.subtitle! == "Airplane" {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.title!!) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!)
            annotationView.image = #imageLiteral(resourceName: "airplane50.png")
            annotationView.canShowCallout = true
            annoView = nil
            annoView2 = nil
        } else {
            
            annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.title!)
            if annotation.subtitle! == "Origin" {
                annoView?.pinTintColor = .green
            }
            annoView?.canShowCallout = true
            annoView2 = nil
            
        }
        
        // Separates annotations to different annotation view so other views are not rotated if the airplane goes off the screen during a polar flight
        return annoView ?? annoView2 ?? annotationView
        
    }
    
    // Based on the destination country, the speech synth will say a welcome message in the local dialect.
    // All Voice Synthesis supported languages are featured here.
    
    func speakWithLocale(airport: Airport?) {
        guard airport != nil else {
            return
        }
        
        let welcomeTerm: String
        let friendTerm: String
        let locale: String
        
        if airport!.country == "US" || airport!.country == "GU" || airport!.country == "VI" || airport!.country == "AS" {
            welcomeTerm = "Welcome to "
            friendTerm = "y'all"
            locale = "en-US"
        } else if airport!.country == "CA" {
            welcomeTerm = "Welcome to "
            friendTerm = "buddy"
            locale = "en-US"
        } else if airport!.country == "AQ" {
            welcomeTerm = "Welcome to "
            friendTerm = "penguin"
            locale = "en-US"
        } else if airport!.country == "GB" || airport!.country == "VG" || airport!.country == "IM" || airport!.country == "GI" || airport!.country == "GG" || airport!.country == "JE" {
            welcomeTerm = "Welcome to "
            friendTerm = "mate"
            locale = "en-GB"
        } else if airport!.country == "IE" {
            welcomeTerm = "Welcome to "
            friendTerm = "boy-o"
            locale = "en-IE"
        } else if airport!.country == "ZA" {
            welcomeTerm = "Welcome to "
            friendTerm = "mate"
            locale = "en-ZA"
        } else if airport!.country == "AU" {
            welcomeTerm = "Welcome to "
            friendTerm = "mate"
            locale = "en-AU"
        } else if airport!.country == "NZ" {
            welcomeTerm = "Haere mai to "
            friendTerm = "tai"
            locale = "en-AU"
        } else if airport!.country == "CK" {
            welcomeTerm = "Kia orana to "
            friendTerm = "tai"
            locale = "en-AU"
        } else if airport!.country == "ES" {
            welcomeTerm = "Bienvenidos a "
            friendTerm = "amigo"
            locale = "es-ES"
        } else if airport!.country == "MX" || airport!.country == "PR" || airport!.country == "CU" || airport!.country == "GT" || airport!.country == "HN" || airport!.country == "NI" || airport!.country == "CR" || airport!.country == "PA" || airport!.country == "CO" || airport!.country == "VE" || airport!.country == "EC" || airport!.country == "BO" || airport!.country == "CL" || airport!.country == "AR" || airport!.country == "PY" || airport!.country == "UY" || airport!.country == "SV" {
            welcomeTerm = "Bienvenidos a "
            friendTerm = "amigo"
            locale = "es-MX"
        } else if airport!.country == "BR" {
            welcomeTerm = "Bem-vindo ao "
            friendTerm = "amigo"
            locale = "pt-BR"
        } else if airport!.country == "PT" || airport!.country == "MO" || airport!.country == "TL" || airport!.country == "CV" {
            welcomeTerm = "Bem-vindo ao "
            friendTerm = "amigo"
            locale = "pt-PT"
        } else if airport!.country == "TO" {
            welcomeTerm = "Talitali fiefia to "
            friendTerm = "kaume'a"
            locale = "en-AU"
        } else if airport!.country == "FR" || airport!.country == "TF" || airport!.country == "GF" || airport!.country == "PF" || airport!.country == "GP" || airport!.country == "HT" || airport!.country == "NC" {
            welcomeTerm = "Bienvenue à "
            friendTerm = "ami"
            locale = "fr-FR"
        } else if airport!.country == "DE" || airport!.country == "CH" || airport!.country == "AT" {
            welcomeTerm = "Willkommen zu "
            friendTerm = "freund"
            locale = "de-DE"
        } else if airport!.country == "NL" || airport!.country == "SR" {
            welcomeTerm = "Welkom bij "
            friendTerm = "vriend"
            locale = "nl-NL"
        } else if airport!.country == "BE" {
            welcomeTerm = "Welkom bij "
            friendTerm = "vriend"
            locale = "nl-BE"
        } else if airport!.country == "IT" {
            welcomeTerm = "Benvenuto a "
            friendTerm = "amico"
            locale = "it-IT"
        } else if airport!.country == "CN" {
            welcomeTerm = "欢迎来到 "
            friendTerm = "朋友"
            locale = "zh-CN"
        } else if airport!.country == "TW" {
            welcomeTerm = "欢迎来到 "
            friendTerm = "朋友"
            locale = "zh-TW"
        } else if airport!.country == "HK" {
            welcomeTerm = "欢迎来到 "
            friendTerm = "朋友"
            locale = "zh-HK"
        } else if airport!.country == "SA" || airport!.country == "DZ" || airport!.country == "KM" || airport!.country == "TD" || airport!.country == "EG" || airport!.country == "ER" || airport!.country == "LY" || airport!.country == "MR" || airport!.country == "MA" || airport!.country == "SS" || airport!.country == "SD" || airport!.country == "TZ" || airport!.country == "TN" || airport!.country == "BH" || airport!.country == "JO" || airport!.country == "IQ" || airport!.country == "KW" || airport!.country == "LB" || airport!.country == "OM" || airport!.country == "PS" || airport!.country == "QA" || airport!.country == "SY" || airport!.country == "AE" || airport!.country == "YE" {
            welcomeTerm = "مرحبا بك في "
            friendTerm = "صديق"
            locale = "ar-SA"
        } else if airport!.country == "GR" {
            welcomeTerm = "Καλωσήρθες στο "
            friendTerm = "φίλος"
            locale = "el-GR"
        } else if airport!.country == "FI" {
            welcomeTerm = "Tervetuloa "
            friendTerm = "ystävä"
            locale = "fi-FI"
        } else if airport!.country == "DK" {
            welcomeTerm = "Velkommen til "
            friendTerm = "ven"
            locale = "da-DK"
        } else if airport!.country == "CZ" {
            welcomeTerm = "Vítejte v "
            friendTerm = "přítel"
            locale = "cs-CZ"
        } else if airport!.country == "IN" {
            welcomeTerm = "आपका स्वागत है "
            friendTerm = "दोस्त"
            locale = "hi-IN"
        } else if airport!.country == "IL" {
            welcomeTerm = " ברוך הבא ל "
            friendTerm = "חָבֵר"
            locale = "he-IL"
        } else if airport!.country == "JP" {
            welcomeTerm = "ようこそ "
            friendTerm = "友人"
            locale = "ja-JP"
        } else if airport!.country == "KR" || airport!.country == "KP" {
            welcomeTerm = "에 오신 것을 환영합니다 "
            friendTerm = "친구"
            locale = "ko-KR"
        } else if airport!.country == "TH" {
            welcomeTerm = "ยินดีต้อนรับสู่ "
            friendTerm = "เพื่อน"
            locale = "th-TH"
        } else if airport!.country == "ID" {
            welcomeTerm = "Selamat Datang di "
            friendTerm = "teman"
            locale = "id-ID"
        } else if airport!.country == "RU" {
            welcomeTerm = "Добро пожаловать в "
            friendTerm = "друг"
            locale = "ru-RU"
        } else if airport!.country == "RO" {
            welcomeTerm = "Bun venit la "
            friendTerm = "prieten"
            locale = "ro-RO"
        } else if airport!.country == "HU" {
            welcomeTerm = "Isten hozott a "
            friendTerm = "barát"
            locale = "hu-HU"
        } else if airport!.country == "TR" {
            welcomeTerm = "Hoşgeldiniz "
            friendTerm = "arkadaş"
            locale = "tr-TR"
        } else if airport!.country == "NO" {
            welcomeTerm = "Velkommen til "
            friendTerm = "venn"
            locale = "no-NO"
        } else if airport!.country == "SE" {
            welcomeTerm = "Välkommen till "
            friendTerm = "vän"
            locale = "sv-SE"
        } else if airport!.country == "SK" {
            welcomeTerm = "Vitajte v "
            friendTerm = "priateľ"
            locale = "sk-SK"
        } else if airport!.country == "PL" {
            welcomeTerm = "Witamy w "
            friendTerm = "przyjaciel"
            locale = "pl-PL"
        }
        else {
            welcomeTerm = "Welcome to "
            friendTerm = ""
            locale = "en-US"
        }
        
        let utterance = AVSpeechUtterance(string: welcomeTerm + airport!.name + " " + friendTerm)
        utterance.voice = AVSpeechSynthesisVoice(language: locale)
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
    }
    
    // Functions to return UILabels made with attributed strings
    
    func getLabelOne() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.center
        
        let attributedStringParagraphStyleOne = NSMutableParagraphStyle()
        attributedStringParagraphStyleOne.alignment = NSTextAlignment.center
        
        let attributedStringParagraphStyleTwo = NSMutableParagraphStyle()
        attributedStringParagraphStyleTwo.alignment = NSTextAlignment.justified
        
        let attributedStringTextAttachment = NSTextAttachment()
        attributedStringTextAttachment.image = #imageLiteral(resourceName: "pageOneImage.png")
        
        let attributedString = NSMutableAttributedString(string: "Welcome to\nGreat Circle Route Mapper\nby Chip Beck\n￼\n\n\nWith Great Circle Route Mapper it is incredibly easy to map a great circle route between any two IATA registered airports in the world — airports like PIT (Pittsburgh), SJC (San Jose), or AKL (Auckland).\n\nAll you have to do is enter two three-letter IATA codes in the two text boxes and press \"Create Great Circle Route\".\n\nOnce created, you can follow a plane flying the route, or explore the route on your own.")
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue", size:14.0)!, range:NSMakeRange(0,10))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue-Bold", size:18.0)!, range:NSMakeRange(11,26))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue", size:14.0)!, range:NSMakeRange(37,13))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:12.0)!, range:NSMakeRange(50,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(54,411))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyle, range:NSMakeRange(0,50))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyleOne, range:NSMakeRange(50,4))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyleTwo, range:NSMakeRange(54,411))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.333, green:0.224, blue:0.0, alpha:1.0), range:NSMakeRange(0,50))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.352, green:0.222, blue:0.0, alpha:1.0), range:NSMakeRange(54,411))
        attributedString.addAttribute(NSAttributedString.Key.attachment, value:attributedStringTextAttachment, range:NSMakeRange(50,1))
        
        let pageOneText = UILabel(frame: CGRect.zero)
        pageOneText.attributedText = attributedString
        pageOneText.backgroundColor = UIColor.clear
        pageOneText.numberOfLines = 20
        pageOneText.frame = CGRect(x: 0, y: 0, width: 460, height: 390)
        pageOneText.center = CGPoint(x: 250.0, y: 200.0)
        
        return pageOneText
    }
    
    func getLabelTwoPtOne() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.left
        
        let attributedStringParagraphStyleOne = NSMutableParagraphStyle()
        attributedStringParagraphStyleOne.alignment = NSTextAlignment.justified
        
        let attributedString = NSMutableAttributedString(string: "But what's a great circle route?\n\nDue to the earth's curvature and un-flatness (sorry flat-earthers), a straight line between two far away points on a rectangular 2D map is often not the shortest route. That's why many flights from the U.S. to Europe pass over Greenland.\n\nRegular 2D maps also become distorted the further the location is from the equator, so apparent distance is also not so accurate.\n\n\n\n")
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue-Bold", size:16.0)!, range:NSMakeRange(0,33))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(33,372))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyle, range:NSMakeRange(0,33))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyleOne, range:NSMakeRange(33,371))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.333, green:0.224, blue:0.0, alpha:1.0), range:NSMakeRange(0,33))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.352, green:0.222, blue:0.0, alpha:1.0), range:NSMakeRange(33,372))
        
        let pageTwoPtOne = UILabel(frame: CGRect.zero)
        pageTwoPtOne.attributedText = attributedString
        pageTwoPtOne.backgroundColor = UIColor.clear
        pageTwoPtOne.numberOfLines = 12
        pageTwoPtOne.frame = CGRect(x: 0, y: 0, width: 337, height: 180)
        pageTwoPtOne.center = CGPoint(x: 203, y: 140)
        return pageTwoPtOne
    }
    
    func getLabelTwoPtTwo() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.justified
        
        let attributedString = NSAttributedString(string: "A great circle route accounts for the curvature, making it the shortest distance between the two points.\n\nAirlines often fly these routes as they save the most time and fuel.", attributes:[NSAttributedString.Key.foregroundColor:UIColor(red:0.352, green:0.222, blue:0.0, alpha:1.0),NSAttributedString.Key.paragraphStyle:attributedStringParagraphStyle,NSAttributedString.Key.font:UIFont(name:"Helvetica", size:13.0)!])
        
        let pageTwoPtTwo = UILabel(frame: CGRect.zero)
        pageTwoPtTwo.attributedText = attributedString
        pageTwoPtTwo.backgroundColor = UIColor.clear
        pageTwoPtTwo.numberOfLines = 10
        pageTwoPtTwo.frame = CGRect(x: 0, y: 0, width: 265, height: 155)
        pageTwoPtTwo.center = CGPoint(x: 168, y: 290)
        return pageTwoPtTwo
    }
    
    func getLabelThree() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.left
        
        let attributedStringParagraphStyleOne = NSMutableParagraphStyle()
        attributedStringParagraphStyleOne.alignment = NSTextAlignment.justified
        
        let attributedStringParagraphStyleTwo = NSMutableParagraphStyle()
        attributedStringParagraphStyleTwo.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "Make sure to check out...\n\n● A polar route! Fly over the poles to see how fast the airplane appears to fly as it gets further from the equator. Notice how the camera zooms in and out as the plane gets closer and farther from the equator. Try SCL to PER or JFK to PEK.\n\n● The local dialect! Over 90 countries will greet you with a special message in the local dialect through voice synthesis if you land there. Try a flight to CDG, MEX, or LHR.\n\n● The airplane's route! You can let the airplane run its course or follow it automatically to its destination.\n\n\nEnjoy!")
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue-Bold", size:16.0)!, range:NSMakeRange(0,27))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(27,65))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica-Oblique", size:13.0)!, range:NSMakeRange(92,7))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(99,459))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica-Bold", size:13.0)!, range:NSMakeRange(558,6))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyle, range:NSMakeRange(0,27))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyleOne, range:NSMakeRange(27,531))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyleTwo, range:NSMakeRange(558,6))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.333, green:0.224, blue:0.0, alpha:1.0), range:NSMakeRange(0,27))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.352, green:0.222, blue:0.0, alpha:1.0), range:NSMakeRange(27,537))
        
        let pageThreeText = UILabel(frame: CGRect.zero)
        pageThreeText.attributedText = attributedString
        pageThreeText.backgroundColor = UIColor.clear
        pageThreeText.numberOfLines = 20
        pageThreeText.frame = CGRect(x: 0, y: 0, width: 430, height: 310)
        pageThreeText.center = CGPoint(x: 250, y: 180)
        return pageThreeText
    }
    
    func getNextLabel() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: "Swipe left to continue  →")
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:10.0)!, range:NSMakeRange(0,24))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:10.0)!, range:NSMakeRange(24,1))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyle, range:NSMakeRange(0,25))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.927, green:0.804, blue:0.611, alpha:1.0), range:NSMakeRange(0,25))
        
        let nextLabel = UILabel(frame: CGRect.zero)
        nextLabel.attributedText = attributedString
        nextLabel.backgroundColor = UIColor.clear
        nextLabel.numberOfLines = 1
        nextLabel.frame = CGRect(x: 0, y: 0, width: 133, height: 16)
        nextLabel.center = CGPoint(x: 430, y: 386)
        return nextLabel
    }
    
    func getExampleTextLabel() -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.left
        
        let attributedString = NSMutableAttributedString(string: "Example IATA Airport Codes and Routes\n\n🇺🇸 : PIT (Pittsburgh), JFK (New York-John F. Kennedy), LAX (Los Angeles), SJC (San Jose), ATL (Atlanta), STL (St. Louis-Lambert)\n\n🇨🇦 : YYZ (Toronto), YUL (Montreal), YVR (Vancouver), YYC (Calgary)\n\n🇲🇽 : MEX (Mexico City), CUN (Cancun), OAX (Oaxaca), DGO (Durango)\n\n🇨🇳 : PVG (Shanghai-Pudong), PEK (Beijing-Capital), Shenzhen (SZX)\n\n🇫🇮 : HEL (Helsinki), Kittila (KTT), Tampere (TMP), Rovaniemi (RVN)\n\n🇦🇺 : SYD (Sydney), MEL (Melbourne), PER (Perth), BNE (Brisbane)\n\nSuggested Polar Routes: PER-SCL (Perth, Australia to Santiago de Chile, Chile), JFK-PEK (New York, NY, to Beijing, PRC)")
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"HelveticaNeue-Bold", size:16.0)!, range:NSMakeRange(0,39))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(39,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(43,128))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(171,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(175,66))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(241,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(245,65))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(310,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(314,65))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(379,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(383,66))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"AppleColorEmoji", size:13.0)!, range:NSMakeRange(449,4))
        attributedString.addAttribute(NSAttributedString.Key.font, value:UIFont(name:"Helvetica", size:13.0)!, range:NSMakeRange(453,182))
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:attributedStringParagraphStyle, range:NSMakeRange(0,635))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.333, green:0.224, blue:0.0, alpha:1.0), range:NSMakeRange(0,39))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor(red:0.352, green:0.222, blue:0.0, alpha:1.0), range:NSMakeRange(39,596))
        
        let exampleCodeLabel = UILabel(frame: .zero)
        exampleCodeLabel.attributedText = attributedString
        exampleCodeLabel.backgroundColor = .clear
        exampleCodeLabel.numberOfLines = 24
        exampleCodeLabel.frame = CGRect(x: 0, y: 0, width: 432, height: 329)
        exampleCodeLabel.center = CGPoint(x: 250, y: 190)
        return exampleCodeLabel
    }
}
