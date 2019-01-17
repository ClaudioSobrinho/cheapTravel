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
    var visiblePolylines = [MKGeodesicPolyline()]
    
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
        clearPolylines()
        guard let originText = originTextField.text,
            let destinationText = destinationTextField.text,
            let originPlace = viewModel.findPlace(from: originText),
            let destinationPlace = viewModel.findPlace(from: destinationText) else {
                priceLabel.text = "Sorry, no flights available"
                return
        }
        
        let path = viewModel.findPath(origin: originPlace, destination: destinationPlace)
        
        if let cost = path.1 {
            priceLabel.text = "\(cost)"
        }
        
        drawPolylines(for: path.0)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //    MARK: Mapview
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
    
    func drawPolylines(for connections: [Connection]) {
        for connection in connections {
            let polyline = MKGeodesicPolyline(coordinates: [connection.origin.coordinates.locationCoordinate2D(), connection.destination.coordinates.locationCoordinate2D()], count: 2)
            
            visiblePolylines.append(polyline)
            mapView.addOverlay(polyline)
        }
        guard let firstConnection = connections.first, let lastConnection = connections.last else {
            return
        }
        let summaryPolyline = MKGeodesicPolyline(coordinates: [firstConnection.origin.coordinates.locationCoordinate2D(), lastConnection.destination.coordinates.locationCoordinate2D()], count: 2)
        setVisibleMapArea(polyline: summaryPolyline, edgeInsets: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
    }
    
    func clearPolylines() {
        for polyline in visiblePolylines {
            mapView.removeOverlay(polyline)
        }
    }
}

