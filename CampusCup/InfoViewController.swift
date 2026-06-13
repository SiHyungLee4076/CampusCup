//
//  InfoViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/24.
//

import UIKit

class InfoViewController: UIViewController {

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = Colors.text
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🔍 음료 카페인 사전"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing = 14
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private let totalAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("➕ 새로운 음료 추가하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandDark
        button.layer.cornerRadius = 14
        return button
    }()

    private var drinkList: [(name: String, caffeine: Int, customImage: UIImage?)] = []
    private let customDrinksKey = "custom_drinks_history_key"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loadAllDrinksData()
        setupUI()
        setupCollectionView()
        
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        totalAddButton.addTarget(self, action: #selector(addNewDrinkPopup), for: .touchUpInside)
    }

    private func loadAllDrinksData() {
        drinkList.removeAll()
        
        DrinkData.drinks.forEach { drink in
            drinkList.append((name: drink.name, caffeine: drink.caffeineAmount, customImage: nil))
        }
        
        if let savedData = UserDefaults.standard.data(forKey: customDrinksKey),
           let decodedList = try? JSONDecoder().decode([CustomDrinkSavedModel].self, from: savedData) {
            decodedList.forEach { savedDrink in
                var loadedImage: UIImage? = nil
                if let imageData = savedDrink.pngImageData {
                    loadedImage = UIImage(data: imageData)
                }
                drinkList.append((name: savedDrink.name, caffeine: savedDrink.caffeine, customImage: loadedImage))
            }
        }
    }

    private func saveCustomDrinkToStorage(name: String, caffeine: Int, image: UIImage?) {
        var currentSavedList: [CustomDrinkSavedModel] = []
        
        if let savedData = UserDefaults.standard.data(forKey: customDrinksKey),
           let decodedList = try? JSONDecoder().decode([CustomDrinkSavedModel].self, from: savedData) {
            currentSavedList = decodedList
        }
        
        let imageData = image?.pngData()
        let newSavedDrink = CustomDrinkSavedModel(name: name, caffeine: caffeine, pngImageData: imageData)
        currentSavedList.append(newSavedDrink)
        
        if let encoded = try? JSONEncoder().encode(currentSavedList) {
            UserDefaults.standard.set(encoded, forKey: customDrinksKey)
        }
    }

    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(totalAddButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        totalAddButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: totalAddButton.topAnchor, constant: -16),

            totalAddButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            totalAddButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            totalAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            totalAddButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DrinkGridCell.self, forCellWithReuseIdentifier: DrinkGridCell.identifier)
    }

    @objc private func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    private var temporaryName: String = ""
    private var temporaryCaffeine: Int = 0

    @objc private func addNewDrinkPopup() {
        let alert = UIAlertController(title: "음료 추가", message: "텍스트 입력 후 앨범에서 사진을 선택합니다.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "음료 이름 (예: 콜드브루 라떼)"
        }
        alert.addTextField { textField in
            textField.placeholder = "카페인 함량 (mg)"
            textField.keyboardType = .numberPad
        }
        
        let nextAction = UIAlertAction(title: "사진 선택하기", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?[0].text, !name.isEmpty,
                  let caffeineStr = alert.textFields?[1].text, let caffeineAmount = Int(caffeineStr) else { return }
            
            self.temporaryName = name
            self.temporaryCaffeine = caffeineAmount
            
            self.openPhotoLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(nextAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
}

extension InfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            
            self.drinkList.append((name: self.temporaryName, caffeine: self.temporaryCaffeine, customImage: selectedImage))
            self.saveCustomDrinkToStorage(name: self.temporaryName, caffeine: self.temporaryCaffeine, image: selectedImage)
            
            self.collectionView.reloadData()
            
            self.temporaryName = ""
            self.temporaryCaffeine = 0
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinkList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkGridCell.identifier, for: indexPath) as? DrinkGridCell else {
            return UICollectionViewCell()
        }
        let drink = drinkList[indexPath.item]
        cell.configure(name: drink.name, caffeine: drink.caffeine, customImage: drink.customImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 14) / 2
        return CGSize(width: width, height: 150)
    }
}

struct CustomDrinkSavedModel: Codable {
    let name: String
    let caffeine: Int
    let pngImageData: Data?
}

final class DrinkGridCell: UICollectionViewCell {
    
    static let identifier = "DrinkGridCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let drinkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()
    
    private let caffeineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.text.withAlphaComponent(0.6)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(drinkImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(caffeineLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        drinkImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        caffeineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            drinkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            drinkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            drinkImageView.widthAnchor.constraint(equalToConstant: 65),
            drinkImageView.heightAnchor.constraint(equalToConstant: 65),
            
            nameLabel.topAnchor.constraint(equalTo: drinkImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            caffeineLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            caffeineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            caffeineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            caffeineLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(name: String, caffeine: Int, customImage: UIImage?) {
        nameLabel.text = name
        caffeineLabel.text = "\(caffeine) mg"
        
        if let custom = customImage {
            drinkImageView.image = custom
        } else if let assetImage = UIImage(named: name) {
            drinkImageView.image = assetImage
        } else {
            drinkImageView.image = UIImage(systemName: "cup.and.saucer.fill")
            drinkImageView.tintColor = Colors.brandDark
        }
    }
}
