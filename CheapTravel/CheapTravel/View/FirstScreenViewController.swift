//
//  FirstScreenViewController.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import UIKit
import MapKit

class FirstScreenViewController: UIViewController {

    //    MARK: Outlets
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //    MARK: Properties
    let viewModel = FirstScreenViewModel(dataFetcher: ConnectionDataFetcher())
    
    //    MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        title = viewModel.title
    }
    
    //    MARK: Actions
    @IBAction func didTouchFindButton(_ sender: Any) {
        guard let originText = originTextField.text else { return }
        if let place = viewModel.findPlace(from: originText) {
            let placeCoordinates = CLLocationCoordinate2D(latitude: place.coordinates.lat, longitude: place.coordinates.long)
            mapView.setCenter(placeCoordinates, animated: true)
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

