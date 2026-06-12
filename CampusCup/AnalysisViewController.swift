//
//  AnalysisViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/24.
//

import UIKit

class AnalysisViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "☕️ 오늘의 대시보드"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private let recommendCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.brandMain.withAlphaComponent(0.4).cgColor
        return view
    }()

    private let recommendTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 누적 섭취량"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Colors.description
        label.textAlignment = .center
        return label
    }()

    private let recommendValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 400 mg"
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "⚠️ 취침 6시간 전! 섭취 주의"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = Colors.brandWarning
        label.textAlignment = .center
        return label
    }()

    private let remainingCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.border.cgColor
        return view
    }()

    private let remainingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🧬 현재 체내 잔여 카페인 상태"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.description
        return label
    }()

    private let remainingValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0 mg"
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = Colors.brandMain
        return label
    }()

    private let feedbackContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = "분석 데이터를 불러오는 중입니다."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.text
        label.numberOfLines = 0
        return label
    }()

    private let timelineSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 섭취 타임라인 (최대 3개)"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = Colors.text
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = false
        return table
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "🌱 오늘 섭취한 카페인이 없습니다!"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.brandSuccess
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📊 주간 통계 리포트 확인하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandMain
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()

    private var recentRecords: [CaffeineRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        
        self.tabBarItem = UITabBarItem(title: "대시보드", image: UIImage(systemName: "chart.bar.doc.horizontal.fill"), selectedImage: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AnalysisTimelineCell.self, forCellReuseIdentifier: "AnalysisTimelineCell")
        
        setupLayout()
        
        reportButton.addTarget(self, action: #selector(moveToReportViewController), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        executeAnalysis()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            recommendCard,
            remainingCard,
            feedbackContainerView,
            timelineSectionLabel,
            tableView,
            reportButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        contentView.addSubview(emptyLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        recommendCard.addSubview(recommendTitleLabel)
        recommendCard.addSubview(recommendValueLabel)
        recommendCard.addSubview(warningLabel)
        recommendTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendValueLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false

        remainingCard.addSubview(remainingTitleLabel)
        remainingCard.addSubview(remainingValueLabel)
        remainingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingValueLabel.translatesAutoresizingMaskIntoConstraints = false

        feedbackContainerView.addSubview(feedbackLabel)
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false

        recommendCard.heightAnchor.constraint(equalToConstant: 140).isActive = true
        remainingCard.heightAnchor.constraint(equalToConstant: 110).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            recommendTitleLabel.topAnchor.constraint(equalTo: recommendCard.topAnchor, constant: 18),
            recommendTitleLabel.leadingAnchor.constraint(equalTo: recommendCard.leadingAnchor, constant: 16),
            recommendTitleLabel.trailingAnchor.constraint(equalTo: recommendCard.trailingAnchor, constant: -16),

            recommendValueLabel.centerYAnchor.constraint(equalTo: recommendCard.centerYAnchor, constant: -5),
            recommendValueLabel.leadingAnchor.constraint(equalTo: recommendCard.leadingAnchor, constant: 16),
            recommendValueLabel.trailingAnchor.constraint(equalTo: recommendCard.trailingAnchor, constant: -16),

            warningLabel.bottomAnchor.constraint(equalTo: recommendCard.bottomAnchor, constant: -14),
            warningLabel.leadingAnchor.constraint(equalTo: recommendCard.leadingAnchor, constant: 16),
            warningLabel.trailingAnchor.constraint(equalTo: recommendCard.trailingAnchor, constant: -16),

            remainingTitleLabel.topAnchor.constraint(equalTo: remainingCard.topAnchor, constant: 16),
            remainingTitleLabel.leadingAnchor.constraint(equalTo: remainingCard.leadingAnchor, constant: 20),
            remainingValueLabel.topAnchor.constraint(equalTo: remainingTitleLabel.bottomAnchor, constant: 6),
            remainingValueLabel.leadingAnchor.constraint(equalTo: remainingCard.leadingAnchor, constant: 20),

            feedbackLabel.topAnchor.constraint(equalTo: feedbackContainerView.topAnchor, constant: 16),
            feedbackLabel.bottomAnchor.constraint(equalTo: feedbackContainerView.bottomAnchor, constant: -16),
            feedbackLabel.leadingAnchor.constraint(equalTo: feedbackContainerView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: feedbackContainerView.trailingAnchor, constant: -16),

            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
        ])
    }

    private func executeAnalysis() {
        guard let user = DrinkData.loadUser() else {
            recommendValueLabel.text = "0 / 400 mg"
            remainingValueLabel.text = "0.0 mg"
            warningLabel.text = "⚠️ 신체 정보 설정 필요"
            warningLabel.textColor = Colors.brandWarning
            recentRecords = []
            tableView.reloadData()
            emptyLabel.isHidden = false
            emptyLabel.text = "⚠️ 마이페이지에서 신체 정보를 먼저 입력해주세요."
            return
        }

        var maxRecommend = 400.0
        if user.age < 19 {
            maxRecommend = user.weight * 2.5
        }

        let allTodayRecords = DrinkData.loadCaffeineRecords()
        let totalToday = allTodayRecords.reduce(0) { $0 + $1.caffeineAmount }
        
        let remaining = allTodayRecords.reduce(0.0) { $0 + calculateRemainingCaffeine(for: $1) }
        remainingValueLabel.text = "\(String(format: "%.1f", remaining)) mg"
        
        let sortedRecords = allTodayRecords.sorted { $0.intakeDate > $1.intakeDate }
        recentRecords = Array(sortedRecords.prefix(3))
        
        recommendValueLabel.text = "\(totalToday) / \(Int(maxRecommend)) mg"
        tableView.reloadData()
        
        if recentRecords.isEmpty {
            emptyLabel.isHidden = false
            emptyLabel.text = "🌱 오늘 섭취한 카페인이 없습니다!"
        } else {
            emptyLabel.isHidden = true
        }

        let calendar = Calendar.current
        let now = Date()
        var targetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = user.sleepHour
        targetComponents.minute = user.sleepMinute
        
        guard let targetSleepDate = calendar.date(from: targetComponents) else { return }
        var sleepDate = targetSleepDate
        if sleepDate < now {
            sleepDate = calendar.date(byAdding: .day, value: 1, to: sleepDate) ?? sleepDate
        }

        let timeToSleep = sleepDate.timeIntervalSince(now)
        let cutoffLimit: Double = 6.0 * 3600.0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let cutTime = calendar.date(byAdding: .hour, value: -6, to: sleepDate) ?? sleepDate
        let cutString = formatter.string(from: cutTime)

        if totalToday > Int(maxRecommend) {
            warningLabel.text = "🚨 하루 권장 최대치 초과! 위험"
            warningLabel.textColor = Colors.brandDanger
            recommendCard.layer.borderColor = Colors.brandDanger.cgColor
            feedbackContainerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            feedbackLabel.text = "🚨 \(user.name)님, 일일 권장량인 \(Int(maxRecommend))mg을 초과하셨습니다. 추가 카페인 유입을 전면 중단하세요."
            feedbackLabel.textColor = Colors.brandDanger
        } else if timeToSleep <= cutoffLimit {
            warningLabel.text = "⚠️ 취침 6시간 전! 섭취 주의"
            warningLabel.textColor = Colors.brandWarning
            recommendCard.layer.borderColor = Colors.brandWarning.cgColor
            feedbackContainerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            feedbackLabel.text = "⏰ 컷오프 한계선: 목표 취침 시간 기준 6시간 전인 [\(cutString)] 구역을 통과했습니다. 안전한 수면 진입을 위해 추가 섭취를 피해 주세요."
            feedbackLabel.textColor = Colors.brandWarning
        } else {
            let hoursLeft = Int(timeToSleep / 3600.0) - 6
            warningLabel.text = "✅ 수면 보호 구역 활성화 중"
            warningLabel.textColor = Colors.brandSuccess
            recommendCard.layer.borderColor = Colors.brandMain.withAlphaComponent(0.4).cgColor
            feedbackContainerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            feedbackLabel.text = "💡 안전 피드백: 취침 제한선인 [\(cutString)]까지 약 \(hoursLeft)시간의 수면 보호 타임이 보장되어 있습니다. 범위 내에서 유연하게 조절하세요."
            feedbackLabel.textColor = Colors.brandSuccess
        }
    }

    private func calculateRemainingCaffeine(for record: CaffeineRecord) -> Double {
        let hoursSinceIntake = Date().timeIntervalSince(record.intakeDate) / 3600.0
        let halfLife: Double = 5.0
        return Double(record.caffeineAmount) * pow(0.5, hoursSinceIntake / halfLife)
    }

    @objc private func moveToReportViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let statisticVC = storyboard.instantiateViewController(withIdentifier: "StatisticViewController") as! StatisticViewController
        statisticVC.modalPresentationStyle = .pageSheet
        self.present(statisticVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnalysisTimelineCell", for: indexPath) as! AnalysisTimelineCell
        let record = recentRecords[indexPath.row]
        cell.configure(record: record)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

class AnalysisTimelineCell: UITableViewCell {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.text
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = Colors.brandMain
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            amountLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: 10),
            amountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(record: CaffeineRecord) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: record.intakeDate)
        
        titleLabel.text = "⏱️ \(timeString) | \(record.drinkName)"
        amountLabel.text = "\(record.caffeineAmount) mg"
    }
}
