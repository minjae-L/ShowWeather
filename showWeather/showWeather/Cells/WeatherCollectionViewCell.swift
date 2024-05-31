//
//  WeatherCollectionViewCell.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "WeatherCollectionViewCell"
    override init(frame: CGRect) {
        super.init(frame: .zero)
//        self.contentView.backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
