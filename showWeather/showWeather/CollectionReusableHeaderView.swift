//
//  CollectionReusableHeaderView.swift
//  showWeather
//
//  Created by 이민재 on 5/28/24.
//

import UIKit

class CollectionReusableHeaderView: UICollectionReusableView {
    static let identifier = "CollectionReusableHeaderView"
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        
        return sb
    }()
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
        configureLayout()
    }
    private func addViews() {
        self.addSubview(searchBar)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
