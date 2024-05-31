//
//  WeatherViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import UIKit

class WeatherViewController: UIViewController {
//    MARK: UI Property
    let viewModel = WeatherViewModel()
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .boldSystemFont(ofSize: 20)
        return lb
    }()
    private let temperatureLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .boldSystemFont(ofSize: 80)
        return lb
    }()
    private let skyInfoLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let rainTypeLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let rainAmountLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let windLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let humidity: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let rainStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 10
        return sv
    }()
    private let humidityStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 10
        return sv
    }()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        
        return cv
    }()
    private func addViews() {
        rainStackView.addArrangedSubview(rainTypeLabel)
        rainStackView.addArrangedSubview(rainAmountLabel)
        humidityStackView.addArrangedSubview(windLabel)
        humidityStackView.addArrangedSubview(humidity)
        contentStackView.addArrangedSubview(addressLabel)
        contentStackView.addArrangedSubview(temperatureLabel)
        contentStackView.addArrangedSubview(skyInfoLabel)
        contentStackView.addArrangedSubview(rainStackView)
        contentStackView.addArrangedSubview(humidityStackView)
        view.addSubview(contentStackView)
        view.addSubview(collectionView)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            
            collectionView.heightAnchor.constraint(equalToConstant: self.view.frame.height/3),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -20),
            contentStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
        ])
    }
    private func configureTexts() {
        guard let element = viewModel.elements.first,let windLabel = element.wind, let humidityLabel = element.humidity else {return}
        self.addressLabel.text = viewModel.address
        self.temperatureLabel.text = element.temp
        switch element.skyInfo {
        case "1":
            self.skyInfoLabel.text = "맑음"
        case "3":
            self.skyInfoLabel.text = "구름많음"
        case "4":
            self.skyInfoLabel.text = "흐림"
        default:
            break
        }
        switch element.rainType {
        case "0":
            self.rainTypeLabel.text = ""
        case "1":
            self.rainTypeLabel.text = "비"
        case "2":
            self.rainTypeLabel.text = "비/눈"
        case "3":
            self.rainTypeLabel.text = "눈"
        case "5":
            self.rainTypeLabel.text = "빗방울"
        case "6":
            self.rainTypeLabel.text = "빗방울/눈날림"
        case "7":
            self.rainTypeLabel.text = "눈날림"
        default:
            break
        }
        switch element.rainAmount {
        case "0":
            self.rainAmountLabel.text = ""
        case "강수없음":
            self.rainAmountLabel.text = ""
        default:
            self.rainAmountLabel.text = element.rainAmount
        }
//        guard let windLabel = element.wind, let humidityLabel = element.humidity else { return }
        self.windLabel.text = "풍속: \(windLabel)m/s"
        self.humidity.text = "습도: \(humidityLabel)%"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        configureLayout()
        view.backgroundColor = .white
        viewModel.delegate = self
    }
    
}


extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier,
                                                            for: indexPath)
                                                            as? WeatherCollectionViewCell else
                                                            { return UICollectionViewCell() }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: self.view.frame.height)
    }
}

extension WeatherViewController: WeatherViewModelDelegate {
    func didUpdatedElements() {
        
        DispatchQueue.main.async {
            self.configureTexts()
            
        }
    }
    
    
}
