//
//  StatisticViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/24.
//

import UIKit

class StatisticViewController: UIViewController {

    private let closeIconButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.text
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "📊 주간 리포트"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 주 요일별 누적 통계"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = Colors.text
        label.textAlignment = .center
        return label
    }()

    private let reportStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 16
        stack.clipsToBounds = true
        return stack
    }()

    private let feedbackCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = "주간 데이터를 분석하고 있습니다."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.text
        label.numberOfLines = 0
        return label
    }()

    private let dashboardReturnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("대시보드로 돌아가기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandDark
        button.layer.cornerRadius = 14
        return button
    }()

    private let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    private var weeklyCaffeineAmounts: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    private var maxRecommendAmount: Double = 400.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        setupUI()
        calculateWeeklyStatistics()
        
        closeIconButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        dashboardReturnButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    }

    private func setupUI() {
        let mainStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            reportStackView,
            feedbackCard
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStackView)
        view.addSubview(closeIconButton)
        view.addSubview(dashboardReturnButton)
        
        closeIconButton.translatesAutoresizingMaskIntoConstraints = false
        dashboardReturnButton.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(feedbackLabel)
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false

        reportStackView.heightAnchor.constraint(equalToConstant: 336).isActive = true
        dashboardReturnButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        NSLayoutConstraint.activate([
            closeIconButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeIconButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            closeIconButton.widthAnchor.constraint(equalToConstant: 44),
            closeIconButton.heightAnchor.constraint(equalToConstant: 44),

            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            feedbackLabel.topAnchor.constraint(equalTo: feedbackCard.topAnchor, constant: 16),
            feedbackLabel.bottomAnchor.constraint(equalTo: feedbackCard.bottomAnchor, constant: -16),
            feedbackLabel.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -16),

            dashboardReturnButton.topAnchor.constraint(greaterThanOrEqualTo: mainStackView.bottomAnchor, constant: 24),
            dashboardReturnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dashboardReturnButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            dashboardReturnButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func calculateWeeklyStatistics() {
        if let user = DrinkData.loadUser() {
            if user.age < 19 {
                maxRecommendAmount = user.weight * 2.5
            } else {
                maxRecommendAmount = 400.0
            }
        }

        let calendar = Calendar.current
        let now = Date()
        
        guard let currentWeekPeriod = calendar.dateInterval(of: .weekOfYear, for: now) else { return }
        let startOfWeek = currentWeekPeriod.start

        weeklyCaffeineAmounts = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

        guard let data = UserDefaults.standard.data(forKey: "caffeine_records_key"),
              let allRecords = try? JSONDecoder().decode([CaffeineRecord].self, from: data) else {
            createWeeklyRows()
            generateFeedbackMessage()
            return
        }

        for record in allRecords {
            if record.intakeDate >= startOfWeek && record.intakeDate <= now {
                let weekdayComponent = calendar.component(.weekday, from: record.intakeDate)
                let arrayIndex = (weekdayComponent == 1) ? 6 : (weekdayComponent - 2)
                if arrayIndex >= 0 && arrayIndex < 7 {
                    weeklyCaffeineAmounts[arrayIndex] += Double(record.caffeineAmount)
                }
            }
        }
        
        createWeeklyRows()
        generateFeedbackMessage()
    }

    private func createWeeklyRows() {
        reportStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        let todayIndex = (currentWeekday == 1) ? 6 : (currentWeekday - 2)
        
        for i in 0..<weekdays.count {
            let dayName = weekdays[i]
            let amount = Int(weeklyCaffeineAmounts[i])
            let isOver = Double(amount) > maxRecommendAmount
            let isToday = (i == todayIndex)
            
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fill
            rowStackView.alignment = .center
            rowStackView.isLayoutMarginsRelativeArrangement = true
            rowStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
            if isToday {
                rowStackView.backgroundColor = Colors.background
                rowStackView.layer.cornerRadius = 12
                rowStackView.layer.borderWidth = 1.5
                rowStackView.layer.borderColor = Colors.brandDark.withAlphaComponent(0.4).cgColor
            } else {
                rowStackView.backgroundColor = .clear
                rowStackView.layer.borderWidth = 0
            }
            
            let dayLabel = UILabel()
            dayLabel.text = isToday ? "\(dayName) (오늘)" : dayName
            dayLabel.font = isToday ? .systemFont(ofSize: 15, weight: .bold) : .systemFont(ofSize: 15, weight: .medium)
            dayLabel.textColor = isToday ? Colors.brandDark : Colors.text
            
            let amountLabel = UILabel()
            amountLabel.font = isToday ? .systemFont(ofSize: 15, weight: .bold) : .systemFont(ofSize: 15, weight: .semibold)
            amountLabel.textAlignment = .right
            
            if isOver {
                amountLabel.text = "\(amount) mg 🚨"
                amountLabel.textColor = Colors.brandDanger
                if isToday { amountLabel.font = .systemFont(ofSize: 15, weight: .black) }
            } else {
                amountLabel.text = "\(amount) mg"
                amountLabel.textColor = isToday ? Colors.brandDark : Colors.text
            }
            
            let spacerView = UIView()
            spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            dayLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            amountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            rowStackView.addArrangedSubview(dayLabel)
            rowStackView.addArrangedSubview(spacerView)
            rowStackView.addArrangedSubview(amountLabel)
            
            reportStackView.addArrangedSubview(rowStackView)
            
            if i < weekdays.count - 1 {
                let separator = UIView()
                separator.backgroundColor = Colors.border.withAlphaComponent(0.4)
                separator.translatesAutoresizingMaskIntoConstraints = false
                reportStackView.addArrangedSubview(separator)
                
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
        }
    }

    private func generateFeedbackMessage() {
        let maxAmount = weeklyCaffeineAmounts.max() ?? 0
        if maxAmount == 0 {
            feedbackCard.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            setFeedbackText(text: "💡 주간 분석 피드백:\n이번 주에는 기록된 카페인 섭취 내역이 없습니다. 아주 청정하고 건강한 한 주를 보내고 계시네요!")
            feedbackLabel.textColor = Colors.brandSuccess
            return
        }

        if let maxIndex = weeklyCaffeineAmounts.firstIndex(of: maxAmount) {
            let targetDay = weekdays[maxIndex]
            
            if maxAmount > maxRecommendAmount {
                feedbackCard.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
                setFeedbackText(text: "💡 주간 분석 피드백:\n이번 주는 \(targetDay)에 과다 섭취했습니다. 평균 취침 시간 유지를 위해 주말 동안 조절이 필요합니다.")
                feedbackLabel.textColor = Colors.brandDanger
            } else {
                feedbackCard.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.08)
                setFeedbackText(text: "💡 주간 분석 피드백:\n이번 주 중 \(targetDay)에 가장 많은 카페인을 소비했습니다. 전반적으로 모든 요일 안전 수치 미만으로 양호하게 관리 중입니다.")
                feedbackLabel.textColor = Colors.text
            }
        }
    }

    private func setFeedbackText(text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        feedbackLabel.attributedText = attributedString
    }

    @objc private func dismissSelf() {
        self.dismiss(animated: true)
    }
}
