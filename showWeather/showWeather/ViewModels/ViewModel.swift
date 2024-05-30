//
//  ViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation

class ViewModel {
    let TO_GRID = 0
    let TO_GPS = 1
    
    var searchBarText = "" {
        didSet {
            print("searchBarText didSet")
        }
    }
    
}
