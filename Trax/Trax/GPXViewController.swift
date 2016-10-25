//
//  ViewController.swift
//  Trax
//
//  Created by Vernsu on 16/10/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import MapKit
class GPXViewController: UIViewController ,MKMapViewDelegate{

    var gpxURL: NSURL?{
        didSet{
            clearWaypoints()
            if let url = gpxURL{
                GPX.parse(url){ gpx in
                    if gpx != nil {
                        self.addWaypoints(gpx!.waypoints)
                    }
                    
                }
            }
        }
    }
    
    private func clearWaypoints(){
        //用？的原因，方法被调用时，segue时，mapView可能不存在
        mapView?.removeAnnotations(mapView.annotations)
    }
    private func addWaypoints(wayPoints : [GPX.Waypoint]){
        mapView?.addAnnotations(wayPoints)
        mapView?.showAnnotations(wayPoints, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if view == nil{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        }else{
            view.annotation = annotation
        }
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint{
            if waypoint.thumbnailURL != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame )
                //具体button的图片，在用户点击的时候再设置
            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton,
            let url = (view.annotation as? GPX.Waypoint)?.thumbnailURL,
            let imageData = NSData(contentsOfURL: url),
            let  image = UIImage(data: imageData)
            
        {
            thumbnailImageButton.setImage(image, forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxURL = NSURL(string: "http://web.stanford.edu/class/cs193p/Vacation.gpx")
    }
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59) // sad face
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
    }

  
}

