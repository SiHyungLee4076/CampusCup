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

    private let nameField = MypageViewController.createInputField(placeholder: "이름")
    private let ageField = MypageViewController.createInputField(placeholder: "나이", keyboard: .numberPad, suffix: "세")
    private let heightField = MypageViewController.createInputField(placeholder: "키", keyboard: .decimalPad, suffix: "cm")
    private let weightField = MypageViewController.createInputField(placeholder: "몸무게", keyboard: .decimalPad, suffix: "kg")

    private let sleepLabel: UILabel = {
        let label = UILabel()
        label.text = "🎯 목표 취침 시간 설정"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Colors.text.withAlphaComponent(0.6)
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
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandDanger
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.fill"), selectedImage: nil)

        setupLayout()
        loadUser()
        setupNotificationCenter()
        
        saveButton.addTarget(self, action: #selector(saveUser), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetUser), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView(arrangedSubviews: [resetButton, saveButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 14
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [
            titleLabel, nameField, ageField, heightField, weightField, sleepLabel, sleepPicker, buttonStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)

        nameField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        ageField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        heightField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        weightField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        sleepPicker.heightAnchor.constraint(equalToConstant: 130).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 52).isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func saveUser() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sleepPicker.date)
        let minute = calendar.component(.minute, from: sleepPicker.date)

        guard let name = nameField.text, !name.isEmpty,
              let ageText = ageField.text, !ageText.isEmpty,
              let heightText = heightField.text, !heightText.isEmpty,
              let weightText = weightField.text, !weightText.isEmpty else {
            showValidationErrorAlert()
            return
        }

        guard let age = Int(ageText),
              let height = Double(heightText),
              let weight = Double(weightText) else {
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
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            UserDefaults.standard.removeObject(forKey: "user_profile_key")
            
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
        ageField.text = "\(user.age)"
        heightField.text = "\(user.height)"
        weightField.text = "\(user.weight)"

        var components = DateComponents()
        components.hour = user.sleepHour
        components.minute = user.sleepMinute

        if let date = Calendar.current.date(from: components) {
            sleepPicker.date = date
        }
    }

    private static func createInputField(placeholder: String, keyboard: UIKeyboardType = .default, suffix: String? = nil) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.keyboardType = keyboard
        tf.textColor = Colors.text
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 12
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 52))
        tf.leftView = leftPadding
        tf.leftViewMode = .always
        
        if let suffixText = suffix {
            let rightLabel = UILabel()
            rightLabel.text = suffixText
            rightLabel.font = .systemFont(ofSize: 15, weight: .medium)
            rightLabel.textColor = Colors.text.withAlphaComponent(0.5)
            
            let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 52))
            rightLabel.frame = CGRect(x: 0, y: 0, width: 35, height: 52)
            rightContainer.addSubview(rightLabel)
            
            tf.rightView = rightContainer
            tf.rightViewMode = .always
        }
        
        return tf
    }
}
