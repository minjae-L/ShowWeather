//
//  WeatherCollectionViewCell.swift
//  showWeather
//
//  Created by 이민재 on 5/31/24.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "WeatherCollectionViewCell"
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 15)
        lb.textAlignment = .center
        return lb
    }()
    private let tempLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .black
        lb.font = .systemFont(ofSize: 20)
        lb.textAlignment = .center
        
        return lb
    }()
    private let skyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        return sv
    }()
    private func addViews() {
        self.contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(dateLabel)
        contentStackView.addArrangedSubview(skyImageView)
        contentStackView.addArrangedSubview(tempLabel)
        
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
    }
    private func configureTimeToHour(dateString: String) -> String {
        if dateString.count == 3 {
            let hour = dateString.prefix(1)
            return "오전 \(hour)시"
        } else {
            let hour = dateString.prefix(2)
            if Int(hour)! > 12 {
                return "오후 \(Int(hour)! - 12)시"
            } else {
                return "오전 \(hour)시"
            }
        }
    }

    func configure(model: WeatherModel) {
        guard let temp = model.temp else { return }
        self.dateLabel.text = configureTimeToHour(dateString: model.date)
        self.tempLabel.text = "\(temp)°"
        switch model.skyInfo {
        case "1":
            self.skyImageView.image = UIImage(systemName: "sun.max.fill")
        case "3":
            self.skyImageView.image = UIImage(systemName: "cloud.sun.fill")
        case "4":
            self.skyImageView.image = UIImage(systemName: "cloud.rain.fill")
        default:
            break
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
