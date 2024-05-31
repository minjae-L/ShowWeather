//
//  DataModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation

// 지역 검색 데이터 모델
struct SearchDataModel {
    let titleLabel: String
    let subTitleLabel: String?
}

// 기상청JSON 데이터 모델
struct WeatherDataModel: Decodable {
    let response: DataResponse
}

struct DataResponse: Decodable {
    let header: ResponseHeader
    let body: ResponseBody?
}
struct ResponseHeader: Decodable {
    let resultCode: String
}

struct ResponseBody: Decodable {
    let items: DataItems
}
struct DataItems: Decodable {
    let item: [ItemModel]
}
struct ItemModel: Decodable {
    let baseDate: String
    let baseTime: String
    let category: String
    let fcstTime: String
    let fcstValue: String
}
