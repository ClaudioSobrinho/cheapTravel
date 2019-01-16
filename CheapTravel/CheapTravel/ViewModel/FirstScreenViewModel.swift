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
    
    private var dataModel: [Connection]! {
        didSet {
            configureOutput()
        }
    }
    
    init(dataFetcher: ConnectionsDataFetcherProtocol) {
        self.dataFetcher = dataFetcher
        viewDidLoad = { [weak self] in
            self?.getPlacesData()
        }
    }
    
    private func getPlacesData() {
        dataFetcher.fetchConnections { [weak self] (connectionList, errorMessage) in
            guard let connections = connectionList else {
                self?.displayError(errorMessage!)
                return
            }
            self?.dataModel = connections
        }
    }
    
    private func configureOutput() {
        title = "Cheap Flights"
    }
    
}
