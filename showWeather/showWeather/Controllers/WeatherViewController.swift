//
//  WeatherViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import UIKit

class WeatherViewController: UIViewController {
    let viewModel = WeatherViewModel()
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let temperatureLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
}

