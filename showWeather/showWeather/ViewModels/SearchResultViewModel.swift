//
//  SearchResultViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
import CoreLocation
import MapKit

// 셀 자동완성 검색을 위한 Delegate
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
    //
//    func getCoordinates(for address: String, completion: @escaping ()->()) {
//        if address == "" {return}
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(address) { (placemarks, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            if let placemark = placemarks?.first, let location = placemark.location {
//                let latitude = location.coordinate.latitude
//                let longitude = location.coordinate.longitude
//                print(" lat: \(latitude), lon: \(longitude)")
//            } else {
//                let noLocationError = NSError(domain: "GeocodingError", code: -1,userInfo: [NSLocalizedDescriptionKey: "No loaction found for the address"])
//                print(noLocationError)
//            }
//        }
//    }
//    데이터모델 형식에 맞춰서 변환
    func fetchData(_ arr: [MKLocalSearchCompletion]?) {
        guard let data = arr else { return }
        var converted: [SearchDataModel] = []
        for element in data {
            converted.append(SearchDataModel(titleLabel: element.title, subTitleLabel: element.subtitle))
        }
        elements = converted
    }
    // MKLocalSearchRequest 생성 -> 선택된 지역의 정보 가져오기(위도,경도)
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
            guard let lati = places?.placemark.coordinate.latitude, let long = places?.placemark.coordinate.longitude else { return }
            let location: LatXLngY = APIManager.shared.convertGRID_GPS(mode: 0, lat_X: lati, lng_Y: long)
            print("converted: \(location)")
            // URLSesison을 통한 네트워크 통신
            APIManager.shared.dataFetch(nx: location.x, ny: location.y) { result in
                switch result {
                case .success(let data):
                    print(data)
                case .failure(.decodingError(error: let error)):
                    print("decodingError: \(error.localizedDescription)")
                case .failure(.invalidUrl):
                    print("invalidURL")
                case .failure(.missingData):
                    print("missingData")
                case .failure(.serverError(code: let code)):
                    print("serverError \(code)")
                case .failure(.transportError):
                    print("transportError")
                }
            }
        }
    }
}
