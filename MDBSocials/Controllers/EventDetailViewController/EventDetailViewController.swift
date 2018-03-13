//
//  EventDetailViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit
import CoreLocation
import MapKit
import GoogleSignIn
import ChameleonFramework
import p2_OAuth2

//var oauth2: OAuth2CodeGrant!

class EventDetailViewController: UIViewController, GIDSignInUIDelegate {

    var nameLabel: UILabel!
    var hostLabel: UILabel!
    var locationLabel: UILabel!
    var dateLabel: UILabel!
    var eventImageView: UIImageView!
    var interestButton: UIButton!
    var interestedButton: UIButton!
    var descriptionLabel: UILabel!
    var mapView: MKMapView!
    var directionsButton: UIButton!
    var calendarButton: UIButton!
    var foaasButton: UIButton!
    var scrollView: UIScrollView!
    var interestedDetailView: InterestedDetailView!
    var modalView: AKModalView!
    
    var post: Post!
    var uid: String!
    
    let FOAASinput = ["awesome", "bag", "because", "bucket", "cup", "diabetes", "everyone", "fascinating", "flying", "fyyff", "give", "looking", "no", "question", "ridiculous", "rtfm", "zayn", "zero"]
    
//    var oauth2: OAuth2CodeGrant!
//    var loader: OAuth2DataLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar"]
        
        setupLabels()
        setupMapView()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
        }
        interestButtonChecked()
        
//        oauth2 = OAuth2CodeGrant(settings: [
//            "client_id": "74606027090-h9tj7kudrb3i0gav2a268416cer4j0de.apps.googleusercontent.com",
//            "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
//            "token_uri": "https://www.googleapis.com/oauth2/v3/token",
//            "scope": "https://www.googleapis.com/auth/calendar",     // depends on the API you use
//            "redirect_uris": ["com.googleusercontent.apps.74606027090-h9tj7kudrb3i0gav2a268416cer4j0de:/oauth"],
//            ])
//        oauth2.authConfig.authorizeEmbedded = true
//        oauth2.authConfig.authorizeContext = self
//
//        loader = OAuth2DataLoader(oauth2: oauth2)
        
    }
    
    func interestButtonChecked() {
        if uid.elementsEqual(post.hostId) || post.interested.contains(uid) {
            interestButton.setTitle("Interested", for: .normal)
            interestButton.backgroundColor = Constants.lightBlueColor
            interestButton.layer.borderWidth = 0
            interestButton.setTitleColor(.white, for: .normal)
        } else {
            interestButton.setTitle("Interested?", for: .normal)
            interestButton.backgroundColor = .white
            interestButton.layer.borderWidth = 1
            interestButton.setTitleColor(.black, for: .normal)
        }
    }
    
    func fetchUsers(uids: [String]) -> Promise<[User]> {
        return Promise { seal in
            let group = DispatchGroup()
            var users: [User] = []
            
            log.info("Fetching users from Firebase.")
            for uid in uids {
                group.enter()
                firstly {
                    return RESTAPIClient.fetchUser(id: uid)
                }.done { user in
                    users.append(user)
                    firstly {
                        return Utils.getImage(withUrl: user.imageUrl)
                    }.done { image in
                        user.image = image
                        group.leave()
                    }
                }
            }
            group.notify(queue: DispatchQueue.main, execute: { () in
                log.info("All users fetched from Firebase.")
                seal.fulfill(users)
            })
        }
    }
    
    func getCoordinates(withBlock: @escaping (CLLocationCoordinate2D) -> ()) {
        let geocoder = CLGeocoder()
        var coordinates: CLLocationCoordinate2D!
        let address = post.location ?? "Calfornia Hall, Sather Rd, Berkeley, CA 94709"
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error == nil {
                let placemark = placemarks?.first
                coordinates = placemark?.location?.coordinate
                withBlock(coordinates)
            } else {
                log.error(error?.localizedDescription)
            }
        }
    }
    
    @objc func getDirections() {
        getCoordinates() { coordinates in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            log.info("Apple Maps opened with directions to event.")
        }
    }
    
    @objc func interestButtonTapped() {
        
        // host has to be interested!
        if !uid.elementsEqual(post.hostId) {
            firstly {
                return FirebaseDBClient.updateInterestedCounter(uid: uid, pid: post.postId)
            }.done { interested in
                self.post.interested = interested
                self.interestedButton.setTitle("Interested: \(self.post.interested.count)", for: .normal)
                self.interestButtonChecked()
            }
        }
    }
    
    @objc func showInterested() {
        let navBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        firstly {
            return fetchUsers(uids: post.interested)
        }.done { users in
            self.interestedDetailView = InterestedDetailView(frame: CGRect(x: 0, y: 70, width: self.view.frame.width - 60, height: self.view.frame.height - 75 - (110 - navBarHeight! - statusBarHeight)), users: users)
            self.modalView = AKModalView(view: self.interestedDetailView)
            self.modalView.dismissAnimation = .FadeOut
            self.navigationController?.view.addSubview(self.modalView)
            self.modalView.show()
        }
    }
    
    @objc func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
        
//        let url = URL(string: "https://www.googleapis.com/auth/calendar")!
//
//        var req = oauth2.request(forURL: url)
//        req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
//
//        self.loader = OAuth2DataLoader(oauth2: oauth2)
//        loader.perform(request: req) { response in
//            do {
//                let dict = try response.responseJSON()
//                DispatchQueue.main.async {
//                    // you have received `dict` JSON data!
//                    print(dict)
//                }
//            }
//            catch let error {
//                DispatchQueue.main.async {
//                    // an error occurred
//                }
//            }
//        }
        
    }
    
    @objc func getFoaas() {
        let i = Int(arc4random_uniform(UInt32(FOAASinput.count)))
        firstly {
            return FOAASClient.getFO(input: FOAASinput[i])
        }.done { text in
            let foaasView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 50))
            let foaasLabel = UILabel(frame: foaasView.frame)
            foaasLabel.text = text
            foaasLabel.textColor = Constants.lightBlueColor
            foaasLabel.backgroundColor = .white
            foaasLabel.textAlignment = .center
            foaasLabel.layer.cornerRadius = 3
            foaasLabel.clipsToBounds = true
            foaasLabel.adjustsFontSizeToFitWidth = true
            foaasView.addSubview(foaasLabel)
            self.modalView = AKModalView(view: foaasView)
            self.modalView.dismissAnimation = .FadeOut
            self.navigationController?.view.addSubview(self.modalView)
            self.modalView.show()
        }
    }
    
    // MARK: Creation functions
    
    func setupLabels() {
        nameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: 50))
        nameLabel.font = UIFont.systemFont(ofSize: 50)
        nameLabel.text = post.name
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textAlignment = .center
        
        hostLabel = UILabel(frame: CGRect(x: 10, y: nameLabel.frame.maxY, width: view.frame.width - 20, height: 20))
        hostLabel.text = "Host: \(post.host!)"
        hostLabel.textAlignment = .center
        
        locationLabel = UILabel(frame: CGRect(x: 10, y: hostLabel.frame.maxY, width: view.frame.width - 20, height: 20))
        let location  = post.location ?? "None"
        locationLabel.text = "\(location)"
        locationLabel.textAlignment = .center
        
        dateLabel = UILabel(frame: CGRect(x: 10, y: locationLabel.frame.maxY, width: view.frame.width - 20, height: 20))
        let date = post.date.split(separator: "\n")
        dateLabel.text = "\(date[1]) \(date[0])"
        dateLabel.textAlignment = .center
        
        interestedButton = UIButton(frame: CGRect(x: 10, y: dateLabel.frame.maxY + 5, width: 150, height: 30))
        interestedButton.contentHorizontalAlignment = .left
        interestedButton.setTitle("Interested: \(post.interested.count)", for: .normal)
        interestedButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        interestedButton.addTarget(self, action: #selector(showInterested), for: .touchUpInside)
        
        
        // places descriptionLabel below image view
        setupImageView()
        
        descriptionLabel = UILabel(frame: CGRect(x: 10, y: eventImageView.frame.maxY + 5, width: view.frame.width - 20, height: 50))
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.text = "Description:\n\(post.description!)"
        descriptionLabel.sizeToFit()
        
        foaasButton = UIButton(frame: CGRect(x: 10, y: descriptionLabel.frame.maxY + 10, width: view.frame.width - 20, height: 40))
        foaasButton.setTitle("Should I go?", for: .normal)
        foaasButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        foaasButton.layer.borderWidth = 1
        foaasButton.layer.borderColor = Constants.lightBlueColor?.cgColor
        foaasButton.addTarget(self, action: #selector(getFoaas), for: .touchUpInside)
    }
    
    func setupImageView() {
        setupInterestButton()
        
        let image = post.image
        let newHeight: Double!
        if image != nil {
            let width = Double((image?.size.width)!)
            let height = Double((image?.size.height)!)
            let aspect = width/height
            newHeight = Double(view.frame.width - 20)/aspect
        } else {
            newHeight = 200
        }
        
        eventImageView = UIImageView(frame: CGRect(x: 10, y: interestButton.frame.maxY + 5, width: view.frame.width - 20, height: CGFloat(newHeight)))
        eventImageView.image = post.image
    }
    
    func setupInterestButton() {
        interestButton = UIButton(frame: CGRect(x: view.frame.width - 110, y: dateLabel.frame.maxY + 5, width: 100, height: 30))
        interestButton.setTitle("Interested?", for: .normal)
        interestButton.setTitleColor(.black, for: .normal)
        interestButton.layer.cornerRadius = 5
        interestButton.layer.borderWidth = 1
        interestButton.layer.borderColor = UIColor.black.cgColor
        interestButton.clipsToBounds = true
        interestButton.addTarget(self, action: #selector(interestButtonTapped), for: .touchUpInside)
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: CGRect(x: 10, y: foaasButton.frame.maxY + 10, width: view.frame.width - 20, height: view.frame.width - 20))
        mapView.showsUserLocation = true
        getCoordinates(withBlock: { coordinates in
            self.mapView.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            self.mapView.addAnnotation(pin)
            self.setupButtons()
        })
    }
    
    func setupButtons() {
        directionsButton = UIButton(frame: CGRect(x: 10, y: mapView.frame.maxY, width: view.frame.width - 20, height: 50))
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.setTitleColor(Constants.lightBlueColor, for: .normal)
        directionsButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        
        calendarButton = UIButton(frame: CGRect(x: 45, y: directionsButton.frame.maxY, width: view.frame.width - 90, height: 40))
        calendarButton.setTitle("Add Event to Google Calendar", for: .normal)
        calendarButton.setTitleColor(.white, for: .normal)
        calendarButton.backgroundColor = UIColor.flatRed()
        calendarButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        
        setupScrollView()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(hostLabel)
        scrollView.addSubview(locationLabel)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(interestedButton)
        scrollView.addSubview(interestButton)
        scrollView.addSubview(eventImageView)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(foaasButton)
        scrollView.addSubview(mapView)
        scrollView.addSubview(directionsButton)
        scrollView.addSubview(calendarButton)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: calendarButton.frame.maxY + 10)
        
        view.addSubview(scrollView)
    }
    
}
