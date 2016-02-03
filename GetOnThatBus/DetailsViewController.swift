//
//  DetailsViewController.swift
//  GetOnThatBus
//
//  Created by John McCants on 2/2/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var busStop : BusStop?
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var routesLabel: UILabel!
    @IBOutlet weak var interModalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.title = busStop?.name
        self.addressLabel.text = busStop?.address
        self.routesLabel.text = busStop?.routes
        self.interModalLabel.text = busStop?.interModal
    }

    
    @IBAction func onBackButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
