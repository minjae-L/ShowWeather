//
//  DataModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation

struct SearchDataModel {
    let titleLabel: String
    let subTitleLabel: String?
}

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
