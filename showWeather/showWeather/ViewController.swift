//
//  ViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/27/24.
//

import UIKit

class ViewController: UIViewController {
    private let TO_GRID = 0
    private let TO_GPS = 1
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        return cv
    }()
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        
        return sb
    }()
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.title = "날씨"
        
    }
    private func addViews() {
        view.addSubview(collectionView)
        view.addSubview(searchBar)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            collectionView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    private func configureColor() {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        configureNavigationBar()
        addViews()
        configureLayout()
        print(APIManager.shared.convertGRID_GPS(mode: TO_GRID, lat_X: 37.4684021, lng_Y: 126.9340142))
    }


}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier,
                                                            for: indexPath)
                                                            as? CollectionViewCell else {
                                                            return UICollectionViewCell()}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 100)
    }
    
}
