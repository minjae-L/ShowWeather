//
//  SearchResultTableViewCell.swift
//  showWeather
//
//  Created by 이민재 on 5/30/24.
//

import UIKit

final class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"
//    MARK: UI Property
    private let mainTitleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 20)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    private let subTitleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 15)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
//    MARK: Methods
    private func addViews() {
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subTitleLabel)
    }
    private func configureLayout() {
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            mainTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            mainTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            subTitleLabel.topAnchor.constraint(equalTo: self.mainTitleLabel.bottomAnchor, constant: 5),
            subTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            subTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            subTitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
        ])
    }
    private func configureColor() {
        mainTitleLabel.textColor = UIColor(named: "LabelTextColor")
        subTitleLabel.textColor = .lightGray
        self.contentView.backgroundColor = UIColor(named: "TableViewCellBackgroundColor")
    }
    func configure(model: SearchDataModel) {
        self.mainTitleLabel.text = model.addressLabel
        self.subTitleLabel.text = model.detailAddressLabel
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: SearchResultTableViewCell.identifier)
        addViews()
        configureLayout()
        configureColor()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
