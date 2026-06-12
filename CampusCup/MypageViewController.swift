//
//  MypageViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/24.
//

import UIKit

class MypageViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 정보"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = Colors.text
        label.textAlignment = .center
        return label
    }()

    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름"
        tf.borderStyle = .roundedRect
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let ageField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "나이"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let heightField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "키 (cm)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let weightField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "몸무게 (kg)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()

    private let sleepLabel: UILabel = {
        let label = UILabel()
        label.text = "🎯 목표 취침 시간 설정"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.description
        return label
    }()

    private let sleepPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandMain
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandDanger
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background

        setupUI()
        loadUser()
        
        self.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.fill"), selectedImage: nil)

        saveButton.addTarget(self, action: #selector(saveUser), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetUser), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        let buttonStackView = UIStackView(arrangedSubviews: [resetButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 15
        buttonStackView.distribution = .fillEqually

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            nameField,
            ageField,
            heightField,
            weightField,
            sleepLabel,
            sleepPicker,
            buttonStackView
        ])

        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        nameField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ageField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        heightField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        weightField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sleepPicker.heightAnchor.constraint(equalToConstant: 120).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10)
        ])
    }

    @objc private func saveUser() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sleepPicker.date)
        let minute = calendar.component(.minute, from: sleepPicker.date)

        guard let name = nameField.text, !name.isEmpty,
              let ageText = ageField.text,
              let heightText = heightField.text,
              let weightText = weightField.text else {
            showValidationErrorAlert()
            return
        }

        let cleanAgeText = ageText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let cleanHeightText = heightText.replacingOccurrences(of: "cm", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanWeightText = weightText.replacingOccurrences(of: "kg", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard let age = Int(cleanAgeText),
              let height = Double(cleanHeightText),
              let weight = Double(cleanWeightText) else {
            showValidationErrorAlert()
            return
        }

        let user = User(
            name: name,
            age: age,
            height: height,
            weight: weight,
            sleepHour: hour,
            sleepMinute: minute
        )

        DrinkData.saveUser(user: user)
        loadUser()

        let alert = UIAlertController(title: "저장 완료", message: "사용자 정보가 안전하게 저장되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showValidationErrorAlert() {
        let alert = UIAlertController(title: "알림", message: "모든 신체 정보를 올바르게 입력해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    @objc private func resetUser() {
        let alert = UIAlertController(title: "정보 초기화", message: "저장된 모든 신체 정보가 삭제됩니다. 진행하시겠습니까?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive, handler: { _ in
            UserDefaults.standard.removeObject(forKey: "user")
            
            self.nameField.text = ""
            self.ageField.text = ""
            self.heightField.text = ""
            self.weightField.text = ""
            self.sleepPicker.date = Date()
            
            let successAlert = UIAlertController(title: "초기화 완료", message: "정보가 성공적으로 포맷되었습니다.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(successAlert, animated: true)
        }))
        
        present(alert, animated: true)
    }

    private func loadUser() {
        guard let user = DrinkData.loadUser() else {
            nameField.text = ""
            ageField.text = ""
            heightField.text = ""
            weightField.text = ""
            sleepPicker.date = Date()
            return
        }

        nameField.text = user.name
        ageField.text = "\(user.age)세"
        heightField.text = "\(user.height) cm"
        weightField.text = "\(user.weight) kg"

        var components = DateComponents()
        components.hour = user.sleepHour
        components.minute = user.sleepMinute

        if let date = Calendar.current.date(from: components) {
            sleepPicker.date = date
        }
    }
}
