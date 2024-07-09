//
//  ViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    private let disposeBag = DisposeBag()
    // 추가버튼 터치시 해당 데이터모델을 변환후 저장, 저장되면 savedWeather에 이벤트발생
    private var saved: [LocationWeatherDataModel] = [] {
        didSet {
            savedWeather.accept(self.saved)
        }
    }
    private(set) var savedWeather = BehaviorRelay<[LocationWeatherDataModel]>(value: [])
    
    // WeatherVC에서 추가버튼 클릭시 델리게이트 패턴을 통해 VC에서 이 함수 실행
    func saveData(model: LocationWeatherDataModel) {
        let nx = Int(model.location.nx)!
        let ny = Int(model.location.ny)!
        APIManager.shared.getData(nx: nx, ny: ny, convenience: true)
            .asObservable()
            .map { [weak self] data in
                return LocationWeatherDataModel(address: model.address,
                                                location: model.location,
                                                savedDataModel: self?.convertData(address: model.address, data: data))
            }
            .subscribe{ [weak self] data in
                guard let element = data.element else { return }
                self?.saved.append(element)
            }
            .disposed(by: disposeBag)
    }
    
    // WeatherDataModel -> SavedWeatherDataModel 로 데이터 변환
    private func convertData(address: String, data: WeatherDataModel) -> SavedWeatherDataModel {
        let failed = SavedWeatherDataModel(address: "", timeStamp: Date(), skyInfo: "", temperature: "", rainAmount: "")
        guard let fcstTime = data.response.body?.items.item[0].fcstTime else { return failed}
        var converted = SavedWeatherDataModel(address: "", timeStamp: Date(), skyInfo: "", temperature: "", rainAmount: "")
        guard let rainAmount = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "RN1"}).first?.fcstValue,
              let temperature = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "T1H"}).first?.fcstValue,
              let sky = data.response.body?.items.item.filter({$0.fcstTime == fcstTime && $0.category == "SKY"}).first?.fcstValue
        else { return failed }
        
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
