//
//  APIManager.swift
//  showWeather
//
//  Created by 이민재 on 5/28/24.
//

import Foundation
import RxSwift
import RxCocoa

// 위도 경도 변환 데이터 모델
struct LatXLngY {
    public var lat: Double
    public var lng: Double
    public var x: Int
    public var y: Int
    
}

// APIManager: URLSession, 위도경도변환함수
class APIManager {
    static let shared = APIManager()
    init() {}
    
    private let disposeBag = DisposeBag()
    private let session = URLSession(configuration: .default)
    
    // MARK: Rx + URLSession
    private func getUrls(convenience: Bool, nx: Int, ny: Int) -> Observable<URLComponents> {
        return Observable.create { observer in
            let scheme = "https"
            let host = "apis.data.go.kr"
            let path = "/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
            
            var arr = [URLComponents]()
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            
            // 현재날짜와 시간 구하기
            let now = Date()
            let before = Calendar.current.date(byAdding: .minute, value: -30, to: now)!
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            timeFormatter.dateFormat = "HHmm"
            let baseDate = dateFormatter.string(from: now)
            let baseTime = timeFormatter.string(from: before)
            
            guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
                print("Error:: can't find api key")
                return Disposables.create()
            }
            guard let dictionary = NSDictionary(contentsOf: url) else {
                print("Error:: api key doesn't loaded")
                return Disposables.create()
            }
            
            // convenience true: URLSession 한번 통신, false: 두번 통신
            if convenience {
                components.percentEncodedQueryItems = [
                    URLQueryItem(name: "serviceKey", value: dictionary["ApiKey"] as! String),
                    URLQueryItem(name: "numOfRows", value: "30"),
                    URLQueryItem(name: "pageNo", value: "1"),
                    URLQueryItem(name: "dataType", value: "JSON"),
                    URLQueryItem(name: "base_date", value: baseDate),
                    URLQueryItem(name: "base_time", value: baseTime),
                    URLQueryItem(name: "nx", value: String(nx)),
                    URLQueryItem(name: "ny", value: String(ny))
                ]
                observer.onNext(components)
            } else {
                // 총 데이터수는 60개지만 1회호출로 가져올 수 있는 데이터의 최대갯수는 50개이므로 두번 걸쳐서 받기위해 URLComponents를 배열로 담아서 리턴
                for i in 1...2 {
                    components.percentEncodedQueryItems = [
                        URLQueryItem(name: "serviceKey", value: dictionary["ApiKey"] as! String),
                        URLQueryItem(name: "numOfRows", value: "30"),
                        URLQueryItem(name: "pageNo", value: String(i)),
                        URLQueryItem(name: "dataType", value: "JSON"),
                        URLQueryItem(name: "base_date", value: baseDate),
                        URLQueryItem(name: "base_time", value: baseTime),
                        URLQueryItem(name: "nx", value: String(nx)),
                        URLQueryItem(name: "ny", value: String(ny))
                    ]
                    observer.onNext(components)
                }
            }
            return Disposables.create()
        }
    }
    func getData(nx: Int, ny: Int, convenience: Bool) -> Observable<WeatherDataModel> {
        return getUrls(convenience: convenience, nx: nx, ny: ny)
            .map{ url in
                return URLRequest(url: url.url!)
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }.share()
            .map{ _, data -> WeatherDataModel in
                let decoder = JSONDecoder()
                let decoded = try? decoder.decode(WeatherDataModel.self, from: data)
                return decoded ?? WeatherDataModel(response: DataResponse(header: ResponseHeader(resultCode: "04"), body: nil))
            }
    }
    
    // MARK: - 위도 경도 변환함수
    func convertGRID_GPS(mode: Int, lat_X: Double, lng_Y: Double) -> LatXLngY {
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO:Double = 43 // 기준점 X좌표(GRID)
        let YO:Double = 136 // 기1준점 Y좌표(GRID)
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        let TO_GRID = 0
        let TO_GPS = 1
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        var rs = LatXLngY(lat: 0, lng: 0, x: 0, y: 0)
        
        if mode == TO_GRID {
            rs.lat = lat_X
            rs.lng = lng_Y
            var ra = tan(Double.pi * 0.25 + (lat_X) * DEGRAD * 0.5)
            ra = re * sf / pow(ra, sn)
            var theta = lng_Y * DEGRAD - olon
            if theta > Double.pi {
                theta -= 2.0 * Double.pi
            }
            if theta < -Double.pi {
                theta += 2.0 * Double.pi
            }
            
            theta *= sn
            rs.x = Int(floor(ra * sin(theta) + XO + 0.5))
            rs.y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        }
        else {
            rs.x = Int(lat_X)
            rs.y = Int(lng_Y)
            let xn = lat_X - XO
            let yn = ro - lng_Y + YO
            var ra = sqrt(xn * xn + yn * yn)
            if (sn < 0.0) {
                ra = -ra
            }
            var alat = pow((re * sf / ra), (1.0 / sn))
            alat = 2.0 * atan(alat) - Double.pi * 0.5
            
            var theta = 0.0
            if (abs(xn) <= 0.0) {
                theta = 0.0
            }
            else {
                if (abs(yn) <= 0.0) {
                    theta = Double.pi * 0.5
                    if (xn < 0.0) {
                        theta = -theta
                    }
                }
                else {
                    theta = atan2(xn, yn)
                }
            }
            let alon = theta / sn + olon
            rs.lat = alat * RADDEG
            rs.lng = alon * RADDEG
        }
        return rs
        
    }


}
