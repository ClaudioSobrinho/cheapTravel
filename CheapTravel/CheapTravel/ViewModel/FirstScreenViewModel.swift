//
//  FirstScreenViewModel.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation

class FirstScreenViewModel {
    
    var dataFetcher: ConnectionsDataFetcherProtocol!
    
    // Output
    var displayError:(String)->() = { _ in }
    var numberOfRows = 0
    var title = ""
    
    // Input
    var viewDidLoad: () -> () = { }
    
    private var connectionsDataModel: [Connection]! {
        didSet {
            configureOutput()
        }
    }
    private var placesDataModel: [Place]!{
        didSet {
            configureOutput()
        }
    }
    
    init(dataFetcher: ConnectionsDataFetcherProtocol) {
        self.dataFetcher = dataFetcher
        viewDidLoad = { [weak self] in
            self?.getData()
        }
    }
    
    private func getData() {
        dataFetcher.fetchData{ [weak self] (data, errorMessage) in
            guard let connections = data?.0, let places = data?.1 else {
                self?.displayError(errorMessage!)
                return
            }
            self?.connectionsDataModel = connections
            self?.placesDataModel = places
        }
    }
    
    private func configureOutput() {
        title = "Cheap Flights"
    }
    
}
