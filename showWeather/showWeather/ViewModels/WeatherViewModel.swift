//
//  WeatherViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

class WeatherViewModel {
    var elements: [WeatherModel] = []
    let disposeBag = DisposeBag()
    var element = BehaviorRelay<[WeatherModel]>(value: [])
    
    init() { }
    convenience init(address: String, completion: MKLocalSearchCompletion?) {
        print("WVM:: convenience init")
        self.init()
        self.address = address
        guard let completion = completion else { return }
        self.search(for: completion)
    }
    var address: String = ""
    private var selectedLocation: (nx: String, ny: String)?
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
        self.element.accept(converted)
    }
    func getLocationDataModel() -> LocationWeatherDataModel? {
        guard let location = self.selectedLocation else { return nil }
        let address = self.address
        return LocationWeatherDataModel(address: address, location: location, savedDataModel: nil)
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
        localSearch.start { [weak self] (response, error) in
            guard error == nil else {
                print("searchError")
                print(error?.localizedDescription)
                return
            }
            guard let self = self else { return }
            let places = response?.mapItems[0]
            guard let lati = places?.placemark.coordinate.latitude, let long = places?.placemark.coordinate.longitude else { return }
            // 불러온 위도 경도를 x좌표,y좌표로 변환
            let location: LatXLngY = APIManager.shared.convertGRID_GPS(mode: 0, lat_X: lati, lng_Y: long)
            self.selectedLocation = (nx: String(location.x), ny: String(location.y))
            // Rx+URLSesison을 통한 네트워크 통신
            APIManager.shared.getData(nx: location.x, ny: location.y, convenience: false)
                .share(replay: 1,scope: .whileConnected)
                .subscribe{[weak self] data in
                    print("WeatherVM Rx Subscribe::")
                    guard let element = data.element else { return }
                    self?.convertDataFromCategory(response: element)
                }
                .disposed(by: self.disposeBag)

        }
    }
    
    func fetchDataFromViewController(nx: Int, ny: Int) {
        APIManager.shared.getData(nx: nx, ny: ny, convenience: false)
            .subscribe{ [weak self] data in
                self?.convertDataFromCategory(response: data)
            }
            .disposed(by: disposeBag)
    }
}
