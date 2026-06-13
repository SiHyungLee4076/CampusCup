//
//  ViewController.swift
//  CampusCup
//
//  Created by hansung on 2026/05/22.
//

import UIKit

class MainViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "CampusCup"
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = Colors.brandDark
        label.textAlignment = .center
        return label
    }()

    private let welcomeCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()

    private let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "반가워요!"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Colors.text
        return label
    }()

    private let welcomeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘도 CampusCup과 함께\n건강한 카페인 루틴을 만들어보세요."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Colors.text
        label.numberOfLines = 0
        return label
    }()

    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "# 핵심 기능 바로가기"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = Colors.text
        return label
    }()

    private let analysisButton = MainViewController.createMenuButton(title: "📊 오늘의 대시보드", subTitle: "잔여량 및 권장량 확인")
    private let recordButton = MainViewController.createMenuButton(title: "📝 카페인 기록하기", subTitle: "마신 음료 실시간 등록")
    private let statisticButton = MainViewController.createMenuButton(title: "📈 주간 통계 리포트", subTitle: "요일별 누적 분석 리포트")
    private let infoButton = MainViewController.createMenuButton(title: "🔍 음료 카페인 사전", subTitle: "브랜드별 카페인 함량 검색")
    private let mypageButton = MainViewController.createMenuButton(title: "👤 내 신체정보 관리", subTitle: "목표 취침 및 신체 설정")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house.fill"), selectedImage: nil)
        
        setupUI()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = DrinkData.loadUser() {
            welcomeTitleLabel.text = "\(user.name)님, 반가워요! ☕️"
        } else {
            welcomeTitleLabel.text = "반가워요! ☕️"
        }
    }

    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(welcomeCardView)
        view.addSubview(menuTitleLabel)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeCardView.translatesAutoresizingMaskIntoConstraints = false
        menuTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        welcomeCardView.addSubview(welcomeTitleLabel)
        welcomeCardView.addSubview(welcomeSubtitleLabel)
        welcomeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let row1 = UIStackView(arrangedSubviews: [analysisButton, recordButton])
        let row2 = UIStackView(arrangedSubviews: [statisticButton, infoButton])
        let row3 = UIStackView(arrangedSubviews: [mypageButton])
        
        [row1, row2, row3].forEach {
            $0.axis = .horizontal
            $0.spacing = 14
            $0.distribution = .fillEqually
        }
        
        let menuStackView = UIStackView(arrangedSubviews: [row1, row2, row3])
        menuStackView.axis = .vertical
        menuStackView.spacing = 14
        menuStackView.distribution = .fill
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuStackView)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            appNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            welcomeCardView.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 20),
            welcomeCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            welcomeCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            welcomeTitleLabel.topAnchor.constraint(equalTo: welcomeCardView.topAnchor, constant: 20),
            welcomeTitleLabel.leadingAnchor.constraint(equalTo: welcomeCardView.leadingAnchor, constant: 20),
            welcomeTitleLabel.trailingAnchor.constraint(equalTo: welcomeCardView.trailingAnchor, constant: -20),
            
            welcomeSubtitleLabel.topAnchor.constraint(equalTo: welcomeTitleLabel.bottomAnchor, constant: 8),
            welcomeSubtitleLabel.leadingAnchor.constraint(equalTo: welcomeCardView.leadingAnchor, constant: 20),
            welcomeSubtitleLabel.trailingAnchor.constraint(equalTo: welcomeCardView.trailingAnchor, constant: -20),
            welcomeSubtitleLabel.bottomAnchor.constraint(equalTo: welcomeCardView.bottomAnchor, constant: -20),

            menuTitleLabel.topAnchor.constraint(equalTo: welcomeCardView.bottomAnchor, constant: 24),
            menuTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            menuStackView.topAnchor.constraint(equalTo: menuTitleLabel.bottomAnchor, constant: 14),
            menuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            menuStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            analysisButton.heightAnchor.constraint(equalToConstant: 72),
            recordButton.heightAnchor.constraint(equalToConstant: 72),
            statisticButton.heightAnchor.constraint(equalToConstant: 72),
            infoButton.heightAnchor.constraint(equalToConstant: 72),
            mypageButton.heightAnchor.constraint(equalToConstant: 72)
        ])
    }

    private func setupActions() {
        analysisButton.addTarget(self, action: #selector(routeToAnalysisTab), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(routeToRecordTab), for: .touchUpInside)
        mypageButton.addTarget(self, action: #selector(routeToMypageTab), for: .touchUpInside)
        
        statisticButton.addTarget(self, action: #selector(presentStatisticScreen), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(presentInfoScreen), for: .touchUpInside)
    }

    @objc private func routeToAnalysisTab() {
        self.tabBarController?.selectedIndex = 1
    }

    @objc private func routeToRecordTab() {
        self.tabBarController?.selectedIndex = 2
    }

    @objc private func routeToMypageTab() {
        self.tabBarController?.selectedIndex = 3
    }

    @objc private func presentStatisticScreen() {
        let statisticVC = StatisticViewController()
        statisticVC.modalPresentationStyle = .fullScreen
        self.present(statisticVC, animated: true)
    }

    @objc private func presentInfoScreen() {
        let infoVC = InfoViewController()
        infoVC.modalPresentationStyle = .fullScreen
        self.present(infoVC, animated: true)
    }

    private static func createMenuButton(title: String, subTitle: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1.0
        button.layer.borderColor = Colors.border.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = Colors.brandDark
        
        let subLabel = UILabel()
        subLabel.text = subTitle
        subLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subLabel.textColor = Colors.text.withAlphaComponent(0.6)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
        return button
    }
}
