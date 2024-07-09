//
//  WeatherViewController.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import UIKit
import RxSwift
import RxCocoa

protocol WeatherViewControllerDelegate: AnyObject {
    func addButtonTapped(data: LocationWeatherDataModel)
    
}
class WeatherViewController: UIViewController {
//    MARK: UI Property
    convenience init(viewModel: WeatherViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var viewModel: WeatherViewModel?
    weak var delegate: WeatherViewControllerDelegate?
    private let disposeBag = DisposeBag()
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .boldSystemFont(ofSize: 40)
        return lb
    }()
    private let temperatureLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .boldSystemFont(ofSize: 80)
        return lb
    }()
    private let skyImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        
        return iv
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
        sv.distribution = .fillEqually
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
        cv.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        cv.clipsToBounds = true
        cv.layer.cornerRadius = 10
        return cv
    }()
    
//    MARK: Methods
    private func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", image: nil, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", image: nil, target: self, action: #selector(addLocationWeather))
    }
    @objc func addLocationWeather() {
        guard let viewModel = viewModel,
              let data = viewModel.getLocationDataModel() else { return }
        delegate?.addButtonTapped(data: data)
        self.dismiss(animated: true)
    }
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    private func addViews() {
        rainStackView.addArrangedSubview(rainTypeLabel)
        rainStackView.addArrangedSubview(rainAmountLabel)
        humidityStackView.addArrangedSubview(windLabel)
        humidityStackView.addArrangedSubview(humidity)
        contentStackView.addArrangedSubview(addressLabel)
        contentStackView.addArrangedSubview(temperatureLabel)
        contentStackView.addArrangedSubview(skyImageView)
        contentStackView.addArrangedSubview(rainStackView)
        contentStackView.addArrangedSubview(humidityStackView)
        view.addSubview(contentStackView)
        view.addSubview(collectionView)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            contentStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -50),

        ])
    }
    private func configureColor() {
        self.addressLabel.textColor = UIColor(named: "LabelTextColor")
        self.temperatureLabel.textColor = UIColor(named: "LabelTextColor")
        self.rainTypeLabel.textColor = UIColor(named: "LabelTextColor")
        self.rainAmountLabel.textColor = UIColor(named: "LabelTextColor")
        self.windLabel.textColor = UIColor(named: "LabelTextColor")
        self.humidity.textColor = UIColor(named: "LabelTextColor")
        self.contentStackView.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        self.rainStackView.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        self.humidityStackView.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
        self.collectionView.backgroundColor = UIColor(named: "CollectionViewCellBackgroundColor")
        self.view.backgroundColor = UIColor(named: "ViewControllerBackgroundColor")
    }

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        configureLayout()
        configureColor()
        configureNavigationBar()
        
        // UI 그리기
        viewModel?.element
            .observe(on: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: { [weak self] model in
                self?.configureTexts(model: model)
            })
            .disposed(by: disposeBag)
        
        // CollectionView Bind
        viewModel?.element
            .observe(on: MainScheduler.instance)
            .asObservable()
            .bind(to: self.collectionView.rx.items(cellIdentifier: WeatherCollectionViewCell.identifier, cellType: WeatherCollectionViewCell.self)) { index, element, cell in
                cell.configure(model: element)
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: CollectionView Delegate, DataSource, DelegateFlowLayout
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: self.collectionView.frame.height)
    }
}

// MARK: UI 그리기
extension WeatherViewController {
    // 날씨 정보로 UI 그리기
    private func configureTexts(model: [WeatherModel]) {
        guard let element = model.first,
              let windLabel = element.wind,
              let humidityLabel = element.humidity,
              let tempText = element.temp
        else {return}
        
        // 주소 라벨
        if viewModel?.address.count ?? 0 > 7 {
            self.addressLabel.font = .boldSystemFont(ofSize: 20)
        } else {
            self.addressLabel.font = .boldSystemFont(ofSize: 40)
        }
        self.addressLabel.text = viewModel?.address
        
        // 온도 라벨
        self.temperatureLabel.text = "\(tempText)°"
        
        // 하늘 이미지 뷰
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        switch element.skyInfo {
        case "1":
            self.skyImageView.image = UIImage(systemName: "sun.max.fill",withConfiguration: imageConfig)
        case "3":
            self.skyImageView.image = UIImage(systemName: "cloud.sun.fill",withConfiguration: imageConfig)
        case "4":
            self.skyImageView.image = UIImage(systemName: "cloud.rain.fill",withConfiguration: imageConfig)
        default:
            break
        }
        
        // 강수형태 라벨
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
        
        // 강수량 라벨
        switch element.rainAmount {
        case "0":
            self.rainAmountLabel.text = ""
        case "강수없음":
            self.rainAmountLabel.text = ""
        default:
            self.rainAmountLabel.text = element.rainAmount
        }
        
        // 바람 라벨
        self.windLabel.text = "풍속: \(windLabel)m/s"
        
        // 습도 라벨
        self.humidity.text = "습도: \(humidityLabel)%"
    }
}
