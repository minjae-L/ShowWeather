//
//  WeatherViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import Foundation
import MapKit

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdatedElements()
}

class WeatherViewModel {
    var elements: [WeatherModel] = [] {
        didSet {
            print("WVM:: elements didSet")
            var allLoaded = false
            if elements[0].wind != nil {
                delegate?.didUpdatedElements()
            }
        }
    }
    weak var delegate: WeatherViewModelDelegate?
    var address: String = ""
    // 지역 검색후 선택시 초기화된다.
    // 초기화되면 선택된 지역의 위도 경도 값을 불러옴 (search)
    var completion: MKLocalSearchCompletion? = nil {
        didSet {
            guard let completion = self.completion else { return }
            self.search(for: completion)
        }
    }
    
    // 날짜를 문자열 형식으로 변환
    // 현재시간 기준으로 6시간후 까지 날씨정보를 불러오기 위함
    private func convertDate(date: String, n: Int) -> String{
        var num = Int(date)! + 100 * n
        if num >= 2400 {
            return String(num - 2400)
        } else {
            return String(num)
        }
    }
    // JSON 데이터모델을 WeatherModel로 변환하여 저장
    private func convertDataFromCategory(response: WeatherDataModel) {
        var converted: [WeatherModel] = []
        if self.elements.isEmpty {
            guard var fcstTime = response.response.body?.items.item[0].fcstTime else { return }
            for i in 0..<6 {
                converted.append(WeatherModel(date: convertDate(date: fcstTime, n: i), temp: nil, rainAmount: nil, rainType: nil, skyInfo: nil, humidity: nil, wind: nil))
            }
        } else {
            converted = self.elements
        }
        
        if response.response.header.resultCode != "00" {
            print("WeatherVM:: Data Error")
            return
        }
        guard let arr = response.response.body?.items.item else { return }
        var idx = 0
        for i in arr {
            var model = converted[idx]
            switch i.category {
            case "T1H":
                model.temp = i.fcstValue
            case "RN1":
                model.rainAmount = i.fcstValue
            case "SKY":
                model.skyInfo = i.fcstValue
            case "REH":
                model.humidity = i.fcstValue
            case "PTY":
                model.rainType = i.fcstValue
            case "WSD":
                model.wind = i.fcstValue
            default:
                continue
            }
            converted[idx] = model
            idx += 1
            if idx > 5 { idx = 0 }
        }
        self.elements = converted
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
            // 불러온 위도 경도를 x좌표,y좌표로 변환
            let location: LatXLngY = APIManager.shared.convertGRID_GPS(mode: 0, lat_X: lati, lng_Y: long)
            print("converted: \(location)")
            // URLSesison을 통한 네트워크 통신
            APIManager.shared.dataFetch(nx: location.x, ny: location.y) {[weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.convertDataFromCategory(response: data)
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
