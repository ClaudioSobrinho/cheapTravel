//
//  FirstScreenViewController.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {

    let viewModel = FirstScreenViewModel(dataFetcher: ConnectionDataFetcher())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         viewModel.viewDidLoad()
    }
}

