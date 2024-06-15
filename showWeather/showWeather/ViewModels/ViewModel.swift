//
//  ViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
protocol ViewModelDelegate: AnyObject {
    func savedWeathersUpdated()
}
class ViewModel {
    weak var delegate: ViewModelDelegate?
    lazy var savedLocationWeatherDataModel: [LocationWeatherDataModel] = [] {
        didSet {
            print("savedLocationWeatherDataModel didSet")
            fetchData(data: self.savedLocationWeatherDataModel)
        }
    }
    private(set) var savedWeathers: [SavedWeatherDataModel] = [] {
        didSet {
            delegate?.savedWeathersUpdated()
            print("savedWeathers didSet")
        }
    }
    
    private func fetchData(data: [LocationWeatherDataModel]) {
        var arr: [SavedWeatherDataModel] = []
        for dm in data {
            let nx = Int(dm.location.nx)!
            let ny = Int(dm.location.ny)!
            
            APIManager.shared.dataFetch(nx: nx, ny: ny, convenience: true) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    if let converted = self.convertData(address: dm.address, data: data) {
                        print("converted success")
                        arr.append(converted)
                        self.savedWeathers = arr
                    }
                case .failure(.decodingError(error: let error)):
                    print("decodingError: \(error)")
                case .failure(.invalidUrl):
                    print("invalidURL Error")
                case .failure(.missingData):
                    print("missingData Error")
                case .failure(.serverError(code: let code)):
                    print("serverError code: \(code)")
                case .failure(.transportError):
                    print("transportError")
                }
            }
        }
        
    }
    private func convertData(address: String, data: WeatherDataModel) -> SavedWeatherDataModel? {
        guard let fcstTime = data.response.body?.items.item[0].fcstTime else { return nil}
        var converted = SavedWeatherDataModel(address: "", timeStamp: Date(), skyInfo: "", temperature: "", rainAmount: "")
        guard let rainAmount = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "RN1"}).first?.fcstValue,
              let temperature = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "T1H"}).first?.fcstValue,
              let sky = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "SKY"}).first?.fcstValue
        else { return nil }
        
        var skyInfo = ""
        switch sky {
        case "1":
            skyInfo = "맑음"
        case "3":
            skyInfo = "구름많음"
        case "4":
            skyInfo = "흐림"
        default:
            skyInfo = ""
        }
        
        return SavedWeatherDataModel(address: address, timeStamp: Date(), skyInfo: skyInfo, temperature: temperature, rainAmount: rainAmount)
    }
    
}
