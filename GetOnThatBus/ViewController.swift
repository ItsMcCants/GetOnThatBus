//
//  ViewController.swift
//  GetOnThatBus
//
//  Created by John McCants on 2/2/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var json = NSDictionary()
    var busStopsArray = [BusStop]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://s3.amazonaws.com/mmios8week/bus.json")
        //Placing the the api site and key as the NSURL
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            do {
                self.json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                let busStops = self.json["row"] as! [NSDictionary]
                for stop : NSDictionary in busStops {
                    self.busStopsArray.append(BusStop(dict: stop))
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    for busStop in self.busStopsArray {
                        let annotation = BusStopMKAnnotation()
                        annotation.busStop = busStop
                        annotation.coordinate = CLLocationCoordinate2DMake(busStop.latitude, busStop.longitude)
                        
                        annotation.title = busStop.name
                        annotation.subtitle = busStop.routes
                        
                        self.mapView.addAnnotation(annotation)
                    }
                    
                    self.zoomToFitMapAnnotations()
                })
            } catch let error as NSError {
                print("There was an error with the JSON data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = annotation as! BusStopMKAnnotation
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        switch annotation.busStop?.interModal {
            case "Metra"?:
                pin.pinTintColor = UIColor.blueColor()
            case "Pace"?:
                pin.pinTintColor = UIColor.blackColor()
            default:
                break
        }
        
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as? BusStopMKAnnotation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewControllerWithIdentifier("detailVC") as! DetailsViewController
        destinationVC.busStop = annotation?.busStop
        self.presentViewController(destinationVC, animated: true, completion: nil)
        
    }
    
    func zoomToFitMapAnnotations() {
        if self.mapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in self.mapView.annotations {
            if !(annotation.coordinate.longitude > -85.0 && annotation.coordinate.latitude < 40.0) {
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
            }
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        
        region = self.mapView.regionThatFits(region)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    @IBAction func onSegmentTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.hidden = false
            self.tableView.hidden = true
        case 1:
            self.mapView.hidden = true
            self.tableView.hidden = false
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busStopsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        let busStop = self.busStopsArray[indexPath.row]
        cell.textLabel?.text = busStop.name
        cell.detailTextLabel?.text = busStop.routes
        
        return cell
    }
}

