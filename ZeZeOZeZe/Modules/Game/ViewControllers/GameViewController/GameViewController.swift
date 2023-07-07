//
//  GameViewController.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseCore
import FirebaseDatabase

class GameViewController: UIViewController {

	private let ref = Database.database().reference()
	
	weak var coordinator: MainCoordinator?

	@IBOutlet private var parentGameView: UIView!
	@IBOutlet private var gameHeaderView: GameHeaderView!
	@IBOutlet private var gettingStartedView: GettingStartedView!
	@IBOutlet private var questionView: QuestionView!
	@IBOutlet private var gameOverView: GameOverView!

	private lazy var gradientLayer: CAGradientLayer = {
		let layer = CAGradientLayer()
		layer.colors = [#colorLiteral(red: 0.9764705882, green: 0.6156862745, blue: 0.2117647059, alpha: 1).cgColor, #colorLiteral(red: 0.9882352941, green: 0.7058823529, blue: 0.3882352941, alpha: 1).cgColor]
		return layer
	}()

	let disposeBag = DisposeBag()

	var viewModel: GameViewModel?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupView()
		setupRx()
	}

	private func setupView() {
		self.view.layer.insertSublayer(self.gradientLayer, at: 0)
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
	}

	private func setupRx() {
		self.rx.sentMessage(#selector(GameViewController.viewDidLayoutSubviews))
			.map({ _ in })
			.subscribe { [weak self] _ in
				guard let self = self else { return }
				self.gradientLayer.frame = self.view.bounds
				self.parentGameView.layer.cornerRadius = min(
					self.parentGameView.bounds.height,
					self.parentGameView.bounds.width
				) / 20
				self.parentGameView.layer.masksToBounds = true
			}
			.disposed(by: disposeBag)

		self.gameHeaderView.rx.back_tapped
			.subscribe(onNext: { [weak self] in
				self?.navigationController?.popViewController(animated: true)
			})
			.disposed(by: disposeBag)

		self.gameOverView.rx.replay_tap
			.map { true }
			.bind(to: self.gameOverView.rx.isHidden)
			.disposed(by: disposeBag)

		self.gameOverView.rx.replay_tap
			.map { false }
			.bind(to: self.gettingStartedView.rx.isHidden)
			.disposed(by: disposeBag)

		self.gameOverView.rx.replay_tap
			.subscribe(onNext: { [weak self] in
				self?.viewModel?.shuffle()
			})
			.disposed(by: disposeBag)

		let input = GameViewModel.Input(
			answer_tapped: self.questionView.rx.answer_tapped
		)
		guard let output = viewModel?.transform(input: input) else { return }

		self.questionView.rx.answer_tapped
			.subscribe(onNext: { (button, question, correct) in
				button?.layer.add({
					let animation = CABasicAnimation(keyPath: "borderColor")
					animation.fromValue = correct ? UIColor.green.cgColor : UIColor.red.cgColor
					animation.toValue = #colorLiteral(red: 0.8980392157, green: 0.8901960784, blue: 0.8901960784, alpha: 1).cgColor
					animation.duration = 0.5
					animation.repeatCount = 1
					return animation
				}(), forKey: "borderColor")
			})
			.disposed(by: disposeBag)

		output.ready_timer
			.drive(self.gettingStartedView.rx.time)
			.disposed(by: disposeBag)

		output.ready_timer_complete
			.map { true }
			.drive(self.gettingStartedView.rx.isHidden)
			.disposed(by: disposeBag)

		output.current_time
			.drive(self.gameHeaderView.rx.time)
			.disposed(by: disposeBag)

		output.current_score
			.drive(self.gameHeaderView.rx.score)
			.disposed(by: disposeBag)

		output.current_score
			.drive(self.gameOverView.rx.score)
			.disposed(by: disposeBag)

		output.current_question
			.bind(to: self.questionView.rx.question)
			.disposed(by: disposeBag)

		output.game_over
			.drive(self.gameOverView.rx.status)
			.disposed(by: disposeBag)

		output.game_over
			.map { _ in false }
			.drive(self.gameOverView.rx.isHidden)
			.disposed(by: disposeBag)

		StorageHandler.shared.best_score_observable
			.compactMap { $0 }
			.do(onNext: { score in
				guard let currentUser = Auth.auth().currentUser else { return }
				let uid = currentUser.uid
				let scoreData: [String: Any] = [
					"username": StorageHandler.shared.nickname ?? "",
					"score": score
				]
				self.ref.child("users").child(uid).setValue(scoreData) { (error, _) in }
			})
			.map { "\($0)" }
			.bind(to: self.gameOverView.rx.record_score)
			.disposed(by: disposeBag)
	}
}
