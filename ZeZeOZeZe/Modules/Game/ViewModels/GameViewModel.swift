//
//  GameViewModel.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct GameViewModel {

	struct Input {
		let answer_tapped: Observable<(UIButton?, Question, Bool)>
	}
	struct Output {
		let ready_timer: Driver<String>
		let ready_timer_complete: Driver<Void>
		let current_time: Driver<String>
		let current_score: Driver<String>
		let current_question: Observable<Question>
		let game_over: Driver<GameOverStatusEnum>
	}

	private let current_score = BehaviorRelay(value: 0)
	private let ready_count_down_complete_subject = PublishSubject<Void>()
	private let current_question_index: BehaviorRelay<Int>
	private let game_over = PublishSubject<GameOverStatusEnum>()

	private let ready_time = 3
	private let questions = BehaviorRelay<[Question]>(value: [])

	init(questions: [Question]) {
		self.questions.accept(questions.shuffled())
		self.current_question_index = BehaviorRelay(value: questions.count - 1)
	}

	func shuffle() {
		self.questions.accept(self.questions.value.shuffled())
		self.current_question_index.accept(self.questions.value.count - 1)
		self.current_score.accept(0)
	}

	func transform(input: Input) -> Output {
		let current_question = self.current_question_index.asObservable()
			.takeWhile { 0 < $0 && $0 < self.questions.value.count }
			.map { self.questions.value[$0] }
			.do(onCompleted: { self.game_over.onNext(.all_questions_answered) })

		let current_score = input.answer_tapped
			.do(onNext: { (_, question, correct) in
				defer { self.current_question_index.accept(self.current_question_index.value - 1) }
				guard correct else { return }
				self.current_score.accept(self.current_score.value + 1)
			})
			.map { $0.0 }
			.flatMap { _ in self.current_score.map { "\($0)" }.asObservable() }

		let ready_timer = self.questions
			.flatMap { _ in
				Observable<Int>
					.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
					.take(self.ready_time + 1)
					.map { "\(self.ready_time - $0)" }
					.do(onCompleted: { self.ready_count_down_complete_subject.onNext(()) })
			}

		enum TimerAction {
			case tick
			case addTwoSeconds
		}

		let timer = Observable<Int>
			.interval(.seconds(1), scheduler: MainScheduler.instance)
			.map { _ in TimerAction.tick }
		let addSeconds = self.current_score.map { _ in }.map { TimerAction.addTwoSeconds }

		let current_time = ready_count_down_complete_subject.asObservable()
			.flatMap {
				Observable
					.merge(timer, addSeconds)
					.scan(into: 13) { totalSeconds, action in
						totalSeconds += action == .addTwoSeconds ? 2 : -1
					}
					.takeUntil(.inclusive) { $0 == 0 }
					.map { "\($0)" }
					.do(onCompleted: { self.game_over.onNext(.time_out) })
			}

		let game_over = self.game_over
			.do(onNext: { _ in
				if StorageHandler.shared.best_score < self.current_score.value {
					StorageHandler.shared.best_score = self.current_score.value
				}
			})

		return Output(
			ready_timer: ready_timer.asDriver(onErrorJustReturn: ""),
			ready_timer_complete: ready_count_down_complete_subject.asDriver(onErrorJustReturn: ()),
			current_time: current_time.asDriver(onErrorJustReturn: ""),
			current_score: current_score.asDriver(onErrorJustReturn: ""),
			current_question: current_question,
			game_over: game_over.asDriver(onErrorJustReturn: .error)
		)
	}
}
