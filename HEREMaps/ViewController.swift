//
//  ViewController.swift
//  HEREMaps
//
//  Created by Joyal Serrao on 09/02/18.
//  Copyright © 2018 Joyal. All rights reserved.
//


import UIKit
import NMAKit

class ViewController: UIViewController {

    @IBOutlet weak var navginationBtn: UIButton!
    @IBOutlet weak var mapView: NMAMapView!

    var router : NMACoreRouter!
    var  route : NMARoute!
    var navigationManager : NMANavigationManager!
    var geoBoundingBox: NMAGeoBoundingBox!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        mapView.zoomLevel = 13.2
        mapView.set(geoCenter: NMAGeoCoordinates(latitude: 17.3850, longitude: 78.4867), animation: .linear)
        mapView.copyrightLogoPosition = NMALayoutPosition.bottomCenter
        
        // Set this controller to be the delegate of NavigationManager, so that it can listening to the
        // navigation events through the different protocols.In this example, we will
        // implement 2 protocol methods for demo purpose, please refer to HERE iOS SDK API documentation
        // for details
        
        
        // Get the NavigationManager instance.It is responsible for providing voice and visual
        // instructions while driving and walking.
        navigationManager = NMANavigationManager.sharedInstance()
        NMANavigationManager.sharedInstance().delegate = self
       // navigationManager?.delegate = self


        // background suport
        NMANavigationManager.sharedInstance().backgroundNavigationEnabled = true

        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func navigationStart(_ sender: Any) {
        
        // To start a turn-by-turn navigation, a concrete route object is required.We use same steps
        // from Routing sample app to create a route from 4350 Still Creek Dr to Langley BC without
        // going on HWY
        // The route calculation requires local map data.Unless there is pre-downloaded map
        // data on device by utilizing MapLoader APIs,it's not recommended to trigger the
        // route calculation immediately after the MapEngine is initialized.The
        // NMARoutingErrorInsufficientMapData error code may be returned by CoreRouter in this case.

        if ((self.route == nil) )
        {
        self.createRoute()

        }
        else
        {
            navigationManager.stop()
            if (NMAPositioningManager.sharedInstance().dataSource?.isKind(of: NMADevicePositionSource.self))! {
                NMAPositioningManager.sharedInstance().dataSource = nil
            }
           
            self.mapView.set(boundingBox: self.geoBoundingBox, animation: NMAMapAnimation.linear)
           self.mapView.orientation = 0.0
            
            self.navigationManager.mapTrackingAutoZoomEnabled = false;
            self.navigationManager.mapTrackingEnabled = false;
            self.navginationBtn.setTitle("Start Navigation", for: .normal)
            self.route = nil;
        
        }
    }
    
}


extension ViewController : NMANavigationManagerDelegate {
    
    func createRoute()  {
        
        
        // Create an NSMutableArray to add two stops
        let  stops : NSMutableArray = NSMutableArray(capacity: 4)
        // START: 4350 Still Creek Dr
        
        let hyderbad = NMAGeoCoordinates.init(latitude: 17.3850, longitude: 78.4867)
        
        let bangalore = NMAGeoCoordinates.init(latitude: 12.9716, longitude: 77.5946)
      
        // END: Langley BC

        stops.add(hyderbad)
        stops.add(bangalore)
        

        
        
        // Create an NMARoutingMode, then set it to find the fastest car route without going
        // on Highway.
        
        let routingMode = NMARoutingMode.init(routingType: .fastest, transportMode: .car, routingOptions: .avoidHighway)
        
        
        // Initialize the NMACoreRouter
        if ((self.router == nil) )
        {
            self.router = NMACoreRouter.init()//[[NMACoreRouter alloc] init];
        }
        
        // Trigger the route calculation
        
        self.router.calculateRoute(withStops: stops as! [Any], routingMode: routingMode) { (routeResult, err) in
            
            
            
            if routeResult != nil   {
           
                if  (routeResult?.routes?.count)! >= 0  {
                    
                  
                        // Let's add the 1st result onto the map
                        self.route = routeResult!.routes![0]
                        let mapRoute = NMAMapRoute.init(self.route)
                        self.mapView.add(mapObject: mapRoute!)
                        
                        // In order to see the entire route, we orientate the
                        // map view
                        // accordingly
                        self.geoBoundingBox = self.route.boundingBox;
                    self.mapView.set(boundingBox: self.route.boundingBox!,animation:NMAMapAnimation.linear)
                    
                        self.startNavigation()
    
                }else{
                    print("error :: no route")
                }
                
                
            }
            
            
            
            
            }
     
        
    }
    
    
    func startNavigation() {
        self.navginationBtn.setTitle("Stop Navigation", for: .normal)
        self.mapView.positionIndicator.isVisible = true

        
        // Configure NavigationManager to launch navigation on current map
        navigationManager.map = self.mapView
        
        
        // device btn
        navigationManager.startTurnByTurnNavigation(self.route)
        
        // Set the map tracking properties
        NMANavigationManager.sharedInstance().mapTrackingEnabled = true
        NMANavigationManager.sharedInstance().mapTrackingAutoZoomEnabled = true
        NMANavigationManager.sharedInstance().mapTrackingOrientation = .dynamic
        NMANavigationManager.sharedInstance().isSpeedWarningEnabled = true
        
    }
    
   
    // Signifies that there is new instruction information available


    
    func navigationManager(_ navigationManager: NMANavigationManager, didUpdateManeuvers maneuver: NMAManeuver?, _ nextManeuver: NMAManeuver?) {
        print(maneuver!)
        print(nextManeuver!)

    }

    
    // Signifies that the system has found a GPS signal
    func navigationManagerDidFindPosition(_ navigationManager: NMANavigationManager) {
        print("New position has been found")
    }

    
    
    
    

    func navigationManager(_ navigationManager: NMANavigationManager, didUpdateRealisticViewsForCurrentManeuver realisticViews: [String : NMAImage]) {
        
        
        
    }
    

    
}






