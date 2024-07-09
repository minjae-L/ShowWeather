//
//  ViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/27/24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
//    MARK: UI Property
    private lazy var collectionView: UICollectionView = {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        addViews()
        configureLayout()
        
        // ViewModel의 savedWeather과 collectionView 바인딩
        viewModel.savedWeather
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: CollectionViewCell.identifier, cellType: CollectionViewCell.self)) { index, element, cell in
                guard let model = element.savedDataModel else  { return }
                cell.configure(model: model)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: UICollectionView Delegate, DataSource, FlowLayoutDelegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width - 40, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.savedWeather.value[indexPath.row]
        let nx = Int(data.location.nx)!
        let ny = Int(data.location.ny)!
        let vm = WeatherViewModel(address: data.address, completion: nil)
        let vc = WeatherViewController(viewModel: vm)
        vc.viewModel?.fetchDataFromViewController(nx: nx, ny: ny)
        self.present(vc, animated: true)
    }
    
}

// MARK: - SearchResultViewControllerDelegate
extension ViewController: SearchResultViewControllerDelegate {
    func didTappedAddButtonFromWeatherVC(data: LocationWeatherDataModel) {
        viewModel.saveData(model: data)
    }
}

// MARK: - UI Property Method
extension ViewController {
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
        searchController.delegate = resultViewController
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
}
