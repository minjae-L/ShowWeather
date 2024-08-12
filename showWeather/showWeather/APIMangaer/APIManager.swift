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
enum NetworkError: Error {
    case invalidUrl
    case transportError
    case serverError(code: Int)
    case missingData
    case decodingError
}

// APIManager: Rx+URLSession, 위도경도변환함수
class APIManager {
    static let shared = APIManager()
    init() {}
    private let disposeBag = DisposeBag()
    private let session = URLSession(configuration: .default)
    private let APIKEY: String = {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url)
        else {
            print("Error:: api key doesn't loaded")
            return ""
        }
        return dictionary["ApiKey"] as! String
    }()
    // 현재시간
    private var currentTime: (baseDate: String, baseTime: String) {
        let now = Date()
        let before = Calendar.current.date(byAdding: .minute, value: -30, to: now)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let baseDate = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "HHmm"
        let baseTime = dateFormatter.string(from: before)
        
        return (baseDate, baseTime)
    }
    // URL Components
    private func component(nx: Int, ny: Int, page: Int) -> URLComponents {
        let scheme = "https"
        let host = "apis.data.go.kr"
        let path = "/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "serviceKey", value: APIKEY),
            URLQueryItem(name: "numOfRows", value: "30"),
            URLQueryItem(name: "pageNo", value: String(page)),
            URLQueryItem(name: "dataType", value: "JSON"),
            URLQueryItem(name: "base_date", value: self.currentTime.baseDate),
            URLQueryItem(name: "base_time", value: self.currentTime.baseTime),
            URLQueryItem(name: "nx", value: String(nx)),
            URLQueryItem(name: "ny", value: String(ny))
        ]
        
        return components
    }
    // MARK: Rx+URLSession
    typealias NetworkResult = Result<WeatherDataModel, NetworkError>
    func fetchData(nx: Int, ny: Int, page: Int) -> Single<NetworkResult> {
        return Single<NetworkResult>.create {[weak self] single in
            // URL 확인
            guard let components = self?.component(nx: nx, ny: ny, page: page) else {
                single(.failure(NetworkError.invalidUrl))
                return Disposables.create()
            }
            
            let request = URLRequest(url: components.url!)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                // 에러 확인
                if let error = error {
                    single(.failure(NetworkError.transportError))
                    return
                }
                
                let successRange = 200..<300
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
                // 접속 코드 확인
                if !successRange.contains(successRange) {
                    single(.failure(NetworkError.serverError(code: statusCode)))
                    return
                }
                // 데이터 확인
                guard let loaded = data else {
                    single(.failure(NetworkError.missingData))
                    return
                }
                // 디코딩 확인
                do {
                    let decoded = try JSONDecoder().decode(WeatherDataModel.self, from: loaded)
                    single(.success(NetworkResult.success(decoded)))
                } catch {
                    single(.failure(NetworkError.decodingError))
                }
            }.resume()
            
            
            return Disposables.create()
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



