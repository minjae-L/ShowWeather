//
//  WeatherViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import Foundation
import MapKit

enum DataInfo: String {
    case temp = "T1H"
    case rainAmount = "RN1"
    case rainType = "PTY"
    case skyInfo = "SKY"
    case humidity = "REH"
    case wind = "WSD"
}
struct WeatherModel {
    
}
class WeatherViewModel {
    var elements: [ItemModel] = []
    var completion: MKLocalSearchCompletion? = nil {
        didSet {
            guard let completion = self.completion else { return }
            self.search(for: completion)
        }
    }
    func convertDataFromCategory() {
        
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
