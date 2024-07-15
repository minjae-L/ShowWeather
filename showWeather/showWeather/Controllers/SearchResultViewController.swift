//
//  SearchResultViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTappedAddButtonFromWeatherVC(data: LocationWeatherDataModel)
}

class SearchResultViewController: UISearchController {
    
    //    MARK: Property
    private let disposeBag = DisposeBag()
    private lazy var viewModel: SearchResultViewModel = {
        let vm = SearchResultViewModel()
        return vm
    }()
    weak var searchResultVCDelegate: SearchResultViewControllerDelegate?
    private lazy var searchCompleter: MKLocalSearchCompleter? = {
        let completer = MKLocalSearchCompleter()
        completer.region = self.searchRegion
        return completer
    }()
    private let searchRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    private var completerResults: [MKLocalSearchCompletion]?
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tv.estimatedRowHeight = 50
        return tv
    }()
    
   // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        configureLayout()
        
        // UISearchController dismiss시 값 초기화
        self.rx.didDismiss
            .subscribe(onNext: { [weak self] in
                self?.viewModel.removeAllElements()
            })
            .disposed(by: disposeBag)
        
        // UISearchResultsUpdating 바인딩
        self.rx.searchPhrase
            .bind(to: searchCompleter!.rx.queryFragment)
            .disposed(by: disposeBag)
        
        // UISearchResultsUpdating가 바인딩되어 값이 변경될 시 구독칸의 함수가 실행됨
        searchCompleter!.rx.didUpdateResults
            .debug("searchCompleter")
            .subscribe {[weak self] completer in
                self?.completerResults = completer.element?.results
                self?.viewModel.fetchData(completer.element?.results)
            }
            .disposed(by: disposeBag)
        
        // 위 바인딩에서 실행된 fetchData에 의해 데이터모델이 변경되고 변경된 모델에 맞춰서 tableViewCell과 바인딩
        viewModel.element
            .observe(on: MainScheduler.instance)
            .debug("viewModel.obs")
            .bind(to: tableView.rx.items(cellIdentifier: SearchResultTableViewCell.identifier, cellType: SearchResultTableViewCell.self)) { index, element, cell in
                cell.configure(model: element)
            }
            .disposed(by: disposeBag)
        
        // tableViewCell 선택시 해당 값을 받고 WeatherViewController 이동
        tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
                guard let self = self,
                      let suggestion = self.completerResults?[indexPath.row] else { return }
                let vm = WeatherViewModel(address: viewModel.element.value[indexPath.row].addressLabel, completion: suggestion)
                let vc = WeatherViewController(viewModel: vm)
                vc.delegate = self
                let navigationController = UINavigationController(rootViewController: vc)
                self.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
// MARK: TableView Delegate
extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension SearchResultViewController: WeatherViewControllerDelegate {
    func addButtonTapped(data: LocationWeatherDataModel) {
        self.dismiss(animated: false)
        searchResultVCDelegate?.didTappedAddButtonFromWeatherVC(data: data)
    }
}

// MARK: UI Methods
extension SearchResultViewController {
        private func addViews() {
            self.view.addSubview(tableView)
        }
        private func configureLayout() {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ])
        }
        private func configureColor() {
            self.tableView.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
            self.view.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        }
}
