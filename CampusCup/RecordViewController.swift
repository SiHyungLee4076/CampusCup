//
//  RecordViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/24.
//

import UIKit

class RecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "➕ 신규 섭취 기록"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private let selectSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "섭취 음료 선택"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.description
        return label
    }()

    private lazy var drinkCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delaysContentTouches = false
        return cv
    }()

    private let customSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "직접 입력 (선택)"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.description
        return label
    }()

    private let customNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "음료 이름을 입력하세요"
        tf.borderStyle = .roundedRect
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let customCaffeineField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "카페인 함량(mg) 입력"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let logButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("오늘의 카페인 등록", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandMain
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()

    private let historyLabel: UILabel = {
        let label = UILabel()
        label.text = "📋 오늘 마신 내역"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = Colors.text
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .secondarySystemBackground
        table.layer.cornerRadius = 12
        table.separatorColor = Colors.border
        return table
    }()

    private var records: [CaffeineRecord] = []
    private var selectedDrinkIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        self.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "doc.plaintext.fill"), selectedImage: nil)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        drinkCollectionView.dataSource = self
        drinkCollectionView.delegate = self
        drinkCollectionView.register(DrinkChipCell.self, forCellWithReuseIdentifier: "ChipCell")

        setupUI()
        loadTodayRecords()

        logButton.addTarget(self, action: #selector(logDrink), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            selectSectionLabel,
            drinkCollectionView,
            customSectionLabel,
            customNameField,
            customCaffeineField,
            logButton,
            historyLabel,
            tableView
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        drinkCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        customNameField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        customCaffeineField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        logButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func loadTodayRecords() {
        records = DrinkData.loadCaffeineRecords()
        tableView.reloadData()
    }

    @objc private func logDrink() {
        var drinkName = ""
        var caffeineAmount = 0

        if let customName = customNameField.text, !customName.isEmpty,
           let customCaffeineText = customCaffeineField.text, let customCaffeine = Int(customCaffeineText) {
            drinkName = customName
            caffeineAmount = customCaffeine
        } else {
            if selectedDrinkIndex < DrinkData.drinks.count {
                let targetDrink = DrinkData.drinks[selectedDrinkIndex]
                drinkName = targetDrink.name
                caffeineAmount = targetDrink.caffeineAmount
            }
        }

        DrinkData.saveCaffeineRecord(name: drinkName, amount: caffeineAmount)
        loadTodayRecords()

        customNameField.text = ""
        customCaffeineField.text = ""
        view.endEditing(true)

        let alert = UIAlertController(title: "등록 완료", message: "\(drinkName)이(가) 기록되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DrinkData.drinks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChipCell", for: indexPath) as! DrinkChipCell
        let drink = DrinkData.drinks[indexPath.item]
        let isSelected = (indexPath.item == selectedDrinkIndex)
        cell.configure(name: drink.name, amount: drink.caffeineAmount, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDrinkIndex = indexPath.item
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let drink = DrinkData.drinks[indexPath.item]
        let text = "\(drink.name) (\(drink.caffeineAmount)mg)"
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let textWidth = text.size(withAttributes: [.font: font]).width
        return CGSize(width: textWidth + 28, height: 36)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let record = records[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: record.intakeDate)
        
        cell.textLabel?.text = "[\(timeString)]  \(record.drinkName)  -  \(record.caffeineAmount)mg"
        cell.textLabel?.textColor = Colors.text
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

class DrinkChipCell: UICollectionViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 18
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, amount: Int, isSelected: Bool) {
        titleLabel.text = "\(name) (\(amount)mg)"
        if isSelected {
            contentView.backgroundColor = Colors.brandMain
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = .secondarySystemBackground
            titleLabel.textColor = Colors.text
        }
    }
}
