//
//  CollectionViewCell.swift
//  showWeather
//
//  Created by 이민재 on 5/28/24.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    private let addressLabel: UILabel = {
        let lb = UILabel()
        lb.text = "서귀포시"
        lb.font = .boldSystemFont(ofSize: 20)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let timeStampLabel: UILabel = {
        let lb = UILabel()
        lb.text = "오후 9:35"
        lb.font = .boldSystemFont(ofSize: 10)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let temperatureLabel: UILabel = {
        let lb = UILabel()
        lb.text = "22°"
        lb.font = .boldSystemFont(ofSize: 40)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let skyInfoLabel: UILabel = {
        let lb = UILabel()
        lb.text = "구름많음"
        lb.font = .boldSystemFont(ofSize: 10)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let rainAmountLabel: UILabel = {
        let lb = UILabel()
        lb.text = "강수량: 1mm"
        lb.font = .boldSystemFont(ofSize: 10)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 20
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins.left = 10
        sv.layoutMargins.right = 10
        return sv
    }()
    private let informationStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alignment = .leading
        sv.spacing = 5
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins.top = 5
        sv.layoutMargins.bottom = 5
        
        return sv
    }()
    private let weatherStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alignment = .trailing
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins.top = 10
        sv.layoutMargins.bottom = 5
        sv.spacing = 10
        
        return sv
    }()
    private func addViews() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(informationStackView)
        contentStackView.addArrangedSubview(weatherStackView)
        informationStackView.addArrangedSubview(addressLabel)
        informationStackView.addArrangedSubview(timeStampLabel)
        informationStackView.addArrangedSubview(skyInfoLabel)
        weatherStackView.addArrangedSubview(temperatureLabel)
        weatherStackView.addArrangedSubview(rainAmountLabel)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
    }
    private func configureColor() {
        contentStackView.backgroundColor = UIColor(named: "CollectionViewCellBackgroundColor")
        informationStackView.backgroundColor = .clear
        weatherStackView.backgroundColor = .clear
        addressLabel.textColor = UIColor(named: "LabelTextColor")
        timeStampLabel.textColor = UIColor(named: "LabelTextColor")
        skyInfoLabel.textColor = UIColor(named: "LabelTextColor")
        temperatureLabel.textColor = UIColor(named: "LabelTextColor")
        rainAmountLabel.textColor = UIColor(named: "LabelTextColor")
        
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addViews()
        self.configureLayout()
        self.configureColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
