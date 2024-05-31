//
//  ViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/27/24.
//

import UIKit

class ViewController: UIViewController {
    private let viewModel = ViewModel()
//    MARK: UI Property
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        return cv
    }()
//    MARK: Methods
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "날씨"
        let resultViewController = SearchResultViewController()
        let searchController = UISearchController(searchResultsController: resultViewController)
        searchController.searchResultsUpdater = resultViewController

        
        self.navigationItem.searchController = searchController
    }
    private func addViews() {
        view.addSubview(collectionView)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    private func configureColor() {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        addViews()
        configureLayout()
        print(APIManager.shared.convertGRID_GPS(mode: viewModel.TO_GRID, lat_X: 37.4684021, lng_Y: 126.9340142))
    }
}

// MARK: UICollectionView Delegate, DataSource, FlowLayoutDelegate
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
        return CGSize(width: self.view.frame.width, height: 70)
    }
    
}
