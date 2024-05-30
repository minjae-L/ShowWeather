//
//  SearchResultViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
import CoreLocation
import MapKit

protocol SearchResultViewModelDelegate: AnyObject {
    func didChangedElements()
}
class SearchResultViewModel {
    weak var delegate: SearchResultViewModelDelegate?
    private(set) var elements: [SearchDataModel] = [] {
        didSet {
            delegate?.didChangedElements()
        }
    }
    init() {
        print("SRVM init")
    }
    var elementsCount: Int {
        return self.elements.count
    }
    func getCoordinates(for address: String, completion: @escaping ()->()) {
        if address == "" {return}
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let placemark = placemarks?.first, let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                print(" lat: \(latitude), lon: \(longitude)")
            } else {
                let noLocationError = NSError(domain: "GeocodingError", code: -1,userInfo: [NSLocalizedDescriptionKey: "No loaction found for the address"])
                print(noLocationError)
            }
        }
    }
    func fetchData(_ arr: [MKLocalSearchCompletion]?) {
        guard let data = arr else { return }
        var converted: [SearchDataModel] = []
        for element in data {
            converted.append(SearchDataModel(titleLabel: element.title, subTitleLabel: element.subtitle))
        }
        elements = converted
    }
    func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = MKCoordinateRegion(MKMapRect.world)
        searchRequest.resultTypes = .address
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) in
            guard error == nil else {
                print("searchError")
                print(error?.localizedDescription)
                return
            }
            let places = response?.mapItems[0]
            print(places?.placemark.coordinate)
        }
    }
}
