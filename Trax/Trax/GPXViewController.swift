//
//  ViewController.swift
//  Trax
//
//  Created by Vernsu on 16/10/25.
//  Copyright © 2016年 Vernsu. All rights reserved.
//

import UIKit
import MapKit
class GPXViewController: UIViewController ,MKMapViewDelegate,UIPopoverPresentationControllerDelegate{

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
        
        view.draggable = annotation is EditableWaypoint
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint{
            if waypoint.thumbnailURL != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame )
                //具体button的图片，在用户点击的时候再设置
            }
            if waypoint is EditableWaypoint{
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)            }
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
        }else if control == view.rightCalloutAccessoryView{
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegueWithIdentifier(Constants.EditUserWaypoint, sender: view)
        }
    }
    
    // MARK: Navigation
    //使用unwind
    @IBAction func updatedUserWaypoint(segue:UIStoryboardSegue){
        selectWaypoint((segue.sourceViewController as? EditWaypointViewController)?.waypointToEdit)
    }
    
    private func selectWaypoint(waypoint: GPX.Waypoint? ){
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let destination = segue.destinationViewController.contentViewController
        let annotationView = sender as? MKAnnotationView
        let waypoint = annotationView?.annotation as? GPX.Waypoint
        
        if segue.identifier == Constants.ShowImageSegue {
            if let ivc = destination as? ImageViewController {
                ivc.imageURL = waypoint?.imageURL
                ivc.title = waypoint?.name
            }
        }else if segue.identifier == Constants.EditUserWaypoint {
            if let ewvc = destination as? EditWaypointViewController,
                let editableWaypoint = waypoint as? EditableWaypoint {
                if let ppc = ewvc.popoverPresentationController{
                    ppc.sourceRect = annotationView!.frame
                    ppc.delegate = self
                }
                ewvc.waypointToEdit = editableWaypoint


            }
        }
        
    }
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
         selectWaypoint((popoverPresentationController.presentedViewController as? EditWaypointViewController)?.waypointToEdit)
    }

  
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController,
        traitCollection: UITraitCollection
        ) -> UIModalPresentationStyle {
        //OverFullScreen时，背景时，是覆盖到本VC上面，背景改为透明就是透明效果
        return traitCollection.horizontalSizeClass == .Compact ? .OverFullScreen: .None
    }
    
    func presentationController(
        controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle
        style: UIModalPresentationStyle
        ) -> UIViewController? {
        if style == .OverFullScreen{
            let navcon = UINavigationController(rootViewController: controller.presentedViewController)
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
            visualEffectView.frame = navcon.view.bounds
            visualEffectView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
            navcon.view.insertSubview(visualEffectView, atIndex: 0)
            return navcon
        }else{
            return nil
        }
    }
 
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began{
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
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

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}


