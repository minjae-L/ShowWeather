//
//  ViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/27/24.
//

import UIKit

class ViewController: UIViewController {
    private lazy var viewModel: ViewModel = {
        let vm = ViewModel()
        vm.delegate = self
        return vm
    }()
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
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "LabelTextColor")]
        appearance.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "날씨"
        let resultViewController = SearchResultViewController()
        resultViewController.delegate = self
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
        self.view.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        self.collectionView.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        addViews()
        configureLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("VC viewWillAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewController viewWillDisappear")
    }
}

// MARK: UICollectionView Delegate, DataSource, FlowLayoutDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.savedWeathers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier,
                                                            for: indexPath)
                                                            as? CollectionViewCell else {
                                                            return UICollectionViewCell()}
        cell.backgroundColor = UIColor(named: "CollectionViewCellBackgroundColor")
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        cell.configure(model: viewModel.savedWeathers[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width - 40, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
}

extension ViewController: SearchResultViewControllerDelegate {
    func didTappedAddButtonFromWeatherVC(data: LocationWeatherDataModel) {
        viewModel.savedLocationWeatherDataModel.append(data)
    }
}

extension ViewController: ViewModelDelegate {
    func savedWeathersUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    
}
