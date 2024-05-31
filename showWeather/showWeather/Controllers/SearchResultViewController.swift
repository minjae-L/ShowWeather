//
//  SearchResultViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import UIKit
import MapKit

class SearchResultViewController: UIViewController {
    private let viewModel = SearchResultViewModel()
    private var searchCompleter: MKLocalSearchCompleter?
    private let searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var completerResults: [MKLocalSearchCompletion]?
//    MARK: UI Property
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        
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
        tableView.backgroundColor = .blue
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SearchResultViewController ViewdidLoad")
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.region = searchRegion
        viewModel.delegate = self
        addViews()
        configureLayout()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchCompleter = nil
    }
}
// MARK: TableView Delegate, Datasource
extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.elementsCount
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell()}
        cell.configure(model: viewModel.elements[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let suggestion = completerResults?[indexPath.row] else { return }
        let vc = WeatherViewController()
        vc.viewModel.completion = suggestion
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
