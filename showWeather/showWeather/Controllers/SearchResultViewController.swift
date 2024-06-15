//
//  SearchResultViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import UIKit
import MapKit
protocol SearchResultViewControllerDelegate: AnyObject {
    func didTappedAddButtonFromWeatherVC(data: LocationWeatherDataModel)
}
class SearchResultViewController: UIViewController {
    private let viewModel = SearchResultViewModel()
    private var searchCompleter: MKLocalSearchCompleter?
    private let searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var completerResults: [MKLocalSearchCompletion]?
    weak var delegate: SearchResultViewControllerDelegate?
//    MARK: UI Property
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tv.estimatedRowHeight = 50
        return tv
    }()
//    MARK: Methods
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
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        configureLayout()
        print("SearchResultViewController ViewdidLoad")
    }
    override func viewWillAppear(_ animated: Bool) {
        print("SRVC viewWillAppear")
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.region = searchRegion
        searchCompleter?.delegate = self
        viewModel.delegate = self
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SRVC viewDidDisappear")
        searchCompleter = nil
        completerResults = nil
        viewModel.removeAllElements()
    }
}
// MARK: TableView Delegate, Datasource
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.elementsCount
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell()}
        cell.configure(model: viewModel.elements[indexPath.row])
        cell.backgroundColor = UIColor(named: "TableViewCellBackgroundColor")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let suggestion = completerResults?[indexPath.row] else { return }
        let root = WeatherViewController()
        root.delegate = self
        root.viewModel.completion = suggestion
        root.viewModel.address = viewModel.elements[indexPath.row].addressLabel
        let vc = UINavigationController(rootViewController: root)
        self.present(vc,animated: true)
    }
    
}
// MARK: UISearchController:: UISearchResultsUpdating
extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print("SRVC:: text: \(text)")
        if text == "" {
            completerResults = nil
        }
        searchCompleter?.queryFragment = text
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchResultViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        guard let arr = completerResults else { return }
        viewModel.fetchData(arr)
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
// MARK: SearchResultViewModelDelegate
extension SearchResultViewController: SearchResultViewModelDelegate {
    func didChangedElements() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SearchResultViewController: WeatherViewControllerDelegate {
    func addButtonTapped(data: LocationWeatherDataModel) {
        print("WVC Delegate")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.dismiss(animated: false)
        }
        delegate?.didTappedAddButtonFromWeatherVC(data: data)
    }
}

