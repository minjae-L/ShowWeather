//
//  ViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/27/24.
//

import UIKit

class ViewController: UIViewController {
    let TO_GRID = 0
    let TO_GPS = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        print(APIManager.shared.convertGRID_GPS(mode: TO_GRID, lat_X: 37.4684021, lng_Y: 126.9340142))
    }


}

