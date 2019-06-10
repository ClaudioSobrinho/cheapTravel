//
//  FirstScreenViewController.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import UIKit
import MapKit

class FirstScreenViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    //    MARK: Outlets
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //    MARK: Properties
    private let viewModel = FirstScreenViewModel(dataFetcher: ConnectionDataFetcher())
    private var visiblePolylines = [MKGeodesicPolyline()]
    private var autoCompleteCharacterCount = 0
    private var timer = Timer()
    
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
        setVisibleMapArea(polyline: summaryPolyline, edgeInsets: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0))
    }
    
    func clearPolylines() {
        for polyline in visiblePolylines {
            mapView.removeOverlay(polyline)
        }
    }
    
    //    MARK: UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //1
        var subString = (textField.text!.capitalized as NSString).replacingCharacters(in: range, with: string) // 2
        subString = formatSubstring(subString: subString)
        
        if subString.count == 0 { // 3 when a user clears the textField
            resetValues(to: textField)
        } else {
            searchAutocompleteEntriesWIthSubstring(substring: subString, in: textField) //4
        }
        return true
    }
    
    func formatSubstring(subString: String) -> String {
        let formatted = String(subString.dropLast(autoCompleteCharacterCount)).lowercased().capitalized //5
        return formatted
    }
    
    func resetValues(to textField: UITextField) {
        autoCompleteCharacterCount = 0
        textField.text = ""
    }
    
    func searchAutocompleteEntriesWIthSubstring(substring: String, in textField: UITextField) {
        let userQuery = substring
        let suggestions = getAutocompleteSuggestions(userText: substring) //1
        
        if suggestions.count > 0 {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //2
                let autocompleteResult = self.formatAutocompleteResult(substring: substring, possibleMatches: suggestions) // 3
                self.putColourFormattedTextInTextField(autocompleteResult: autocompleteResult, userQuery : userQuery, in: textField) //4
                self.moveCaretToEndOfUserQueryPosition(userQuery: userQuery, in: textField) //5
            })
        } else {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in //7
                textField.text = substring
            })
            autoCompleteCharacterCount = 0
        }
    }
    
    //    MARK: Auxiliar functions
    func getAutocompleteSuggestions(userText: String) -> [String]{
        var possibleMatches: [String] = []
        for item in viewModel.getAutocompletePossibilities() { //2
            let myString:NSString! = item as NSString
            let substringRange :NSRange! = myString.range(of: userText)
            
            if (substringRange.location == 0)
            {
                possibleMatches.append(item)
            }
        }
        return possibleMatches
    }
    
    func putColourFormattedTextInTextField(autocompleteResult: String, userQuery : String, in textField: UITextField) {
        let colouredString: NSMutableAttributedString = NSMutableAttributedString(string: userQuery + autocompleteResult)
        colouredString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location: userQuery.count,length:autocompleteResult.count))
        textField.attributedText = colouredString
    }
    
    func moveCaretToEndOfUserQueryPosition(userQuery : String, in textField: UITextField) {
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: userQuery.count) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        let selectedRange: UITextRange? = textField.selectedTextRange
        textField.offset(from: textField.beginningOfDocument, to: (selectedRange?.start)!)
    }
    func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
        var autoCompleteResult = possibleMatches[0]
        autoCompleteResult.removeSubrange(autoCompleteResult.startIndex..<autoCompleteResult.index(autoCompleteResult.startIndex, offsetBy: substring.count))
        autoCompleteCharacterCount = autoCompleteResult.count
        return autoCompleteResult
    }
}

