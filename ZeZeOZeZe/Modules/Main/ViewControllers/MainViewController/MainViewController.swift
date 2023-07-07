//
//  ViewController.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

	weak var coordinator: MainCoordinator?

	@IBOutlet private var checkbox1: CheckboxButton!
	@IBOutlet private var checkbox2: CheckboxButton!
	@IBOutlet private var checkbox3: CheckboxButton!
	@IBOutlet private var checkbox4: CheckboxButton!
	@IBOutlet private var play_btn: UIButton!
	@IBOutlet private var leaderboard_btn: UIButton!
	@IBOutlet private var about_btn: UIButton!
	@IBOutlet private var best_score_label: UILabel!

	private lazy var gradientLayer: CAGradientLayer = {
		let layer = CAGradientLayer()
		layer.colors = [#colorLiteral(red: 0.9764705882, green: 0.6156862745, blue: 0.2117647059, alpha: 1).cgColor, #colorLiteral(red: 0.9882352941, green: 0.7058823529, blue: 0.3882352941, alpha: 1).cgColor]
		return layer
	}()

	private let disposeBag = DisposeBag()

	private lazy var viewModel = MainViewModel(questionsService: self)

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupView()
		setupRx()
	}

	private func setupView() {
		self.view.layer.insertSublayer(self.gradientLayer, at: 0)
	}

	private func setupRx() {
		self.rx.sentMessage(#selector(MainViewController.viewDidLayoutSubviews))
			.map({ _ in })
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.gradientLayer.frame = self.view.bounds
			})
			.disposed(by: disposeBag)

		let input = MainViewModel.Input(
			user_nickname: StorageHandler.shared.nickname_observable,
			checkbox1_selected: checkbox1.isSelectedObservable,
			checkbox2_selected: checkbox2.isSelectedObservable,
			checkbox3_selected: checkbox3.isSelectedObservable,
			checkbox4_selected: checkbox4.isSelectedObservable,
			play: self.play_btn.rx.tap.asObservable(),
			leaderboard: self.leaderboard_btn.rx.tap.asObservable(),
			about: self.about_btn.rx.tap.asObservable()
		)
		let output = viewModel.transform(input: input)

		self.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:))).map({ _ in })
			.withLatestFrom(output.set_nickname)
			.subscribe(onNext: { [weak self] (bool) in
				guard let self = self else { return }
				guard bool else { return }
				let alertController = UIAlertController(title: "בחר כינוי למשחק", message: nil, preferredStyle: .alert)
				let saveAction = UIAlertAction(title: "המשך", style: .default, handler: { _ in
					StorageHandler.shared.nickname = alertController.textFields?.first?.text
				})
				alertController.addTextField { [weak self] (textField) in
					guard let self = self else { return }
					textField.textAlignment = .center
					textField.placeholder = "הכנס שם"
					textField.rx.text
						.subscribe(onNext: { (text) in
							saveAction.isEnabled = (text?.count ?? 0) >= 2 && (text?.count ?? 0) <= 10
						})
						.disposed(by: self.disposeBag)
				}
				alertController.addAction(saveAction)
				self.present(alertController, animated: true)
			})
			.disposed(by: disposeBag)

		output.can_play
			.drive(self.play_btn.rx.isEnabled)
			.disposed(by: disposeBag)

		output.questions
			.drive(onNext: { [weak self] questions in
				self?.coordinator?.startGame(with: questions)
			})
			.disposed(by: disposeBag)

		StorageHandler.shared.best_score_observable
			.compactMap { $0 }
			.map { "\($0)" }
			.bind(to: self.best_score_label.rx.text)
			.disposed(by: disposeBag)
	}
}

extension MainViewController: QuestionsService {
	func getQuestions() -> Observable<[Question]> {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard
			let path = Bundle(for: type(of: self)).path(forResource: "Questions", ofType: "json"),
			let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
			let questions = try? decoder.decode([Question].self, from: data) else { return .empty() }
		return .just(questions)
	}
}
