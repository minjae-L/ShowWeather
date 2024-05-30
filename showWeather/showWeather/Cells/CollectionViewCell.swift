//
//  CollectionViewCell.swift
//  showWeather
//
//  Created by 이민재 on 5/28/24.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.contentView.backgroundColor = .brown
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
