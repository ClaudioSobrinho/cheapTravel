//
//  FirstScreenViewController.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import UIKit
import MapKit

class FirstScreenViewController: UIViewController, MKMapViewDelegate {

    //    MARK: Outlets
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //    MARK: Properties
    let viewModel = FirstScreenViewModel(dataFetcher: ConnectionDataFetcher())
    var visiblePolyline = MKGeodesicPolyline()
    
    //    MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.mapView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        title = viewModel.title
    }
    
    //    MARK: Actions
    @IBAction func didTouchFindButton(_ sender: Any) {
        mapView.removeOverlay(visiblePolyline)
        guard let originText = originTextField.text else { return }
        guard let destinationText = destinationTextField.text else { return }
        if let place = viewModel.findPlace(from: originText) {
            let placeCoordinates = place.coordinates.locationCoordinate2D()
            mapView.setCenter(placeCoordinates, animated: true)
        }
        if let connection = viewModel.findConnection(origin: originText, destination: destinationText) {
            priceLabel.text = "\(connection.price)"
            visiblePolyline = MKGeodesicPolyline(coordinates: [connection.origin.coordinates.locationCoordinate2D(), connection.destination.coordinates.locationCoordinate2D()], count: 2)
            mapView.addOverlay(visiblePolyline)
            setVisibleMapArea(polyline: visiblePolyline, edgeInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        } else {
            priceLabel.text = "Sorry, no flights available"
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {

            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
}

