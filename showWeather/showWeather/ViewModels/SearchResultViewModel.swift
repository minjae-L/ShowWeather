//
//  SearchResultViewModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
//import CoreLocation
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
//    데이터모델 형식에 맞춰서 변환
    func fetchData(_ arr: [MKLocalSearchCompletion]?) {
        guard let data = arr else { return }
        var converted: [SearchDataModel] = []
        for element in data {
            converted.append(SearchDataModel(titleLabel: element.title, subTitleLabel: element.subtitle))
        }
        elements = converted
    }
}
