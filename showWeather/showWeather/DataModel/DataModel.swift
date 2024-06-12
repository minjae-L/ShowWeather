//
//  DataModel.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import Foundation
// 저장된 지역의 날씨 모델
struct LocationWeatherDataModel {
    let address: String
    let location: (nx: String, ny: String)
}
// 지역 검색 데이터 모델
struct SearchDataModel {
    let addressLabel: String
    let detailAddressLabel: String?
}
// 날씨정보 데이터 모델(Weather VC에 뿌려질 데이터)
/*
 date: 날짜
 temp: 기온
 rainAmount: 강수량
 rainType: 강수형태(비, 눈, 빗방울)
 skyInfo: 하늘상태(맑음, 구름많음, 흐림)
 humidity: 습도
 wind: 풍속
 */
struct WeatherModel {
    let date: String
    var temp: String?
    var rainAmount: String?
    var rainType: String?
    var skyInfo: String?
    var humidity: String?
    var wind: String?
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
