//
//  MainViewModel.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

struct MainViewModel {
	struct Input {
		let user_nickname: Observable<String?>
		let checkbox1_selected: Observable<Bool>
		let checkbox2_selected: Observable<Bool>
		let checkbox3_selected: Observable<Bool>
		let checkbox4_selected: Observable<Bool>
		let play: Observable<Void>
		let leaderboard: Observable<Void>
		let about: Observable<Void>
	}
	struct Output {
		let set_nickname: Driver<Bool>
		let can_play: Driver<Bool>
		let questions: Driver<[Question]>
		let best_score: Driver<Int>
	}

	private let ref = Database.database().reference()
	
	let questionsService: QuestionsService

	private let checkbox1_status = BehaviorRelay(value: false)
	private let checkbox2_status = BehaviorRelay(value: false)
	private let checkbox3_status = BehaviorRelay(value: false)
	private let checkbox4_status = BehaviorRelay(value: false)

	func transform(input: Input) -> Output {
		let questions = questionsService.getQuestions()
		let can_play: Observable<Bool> = Observable.combineLatest(
			questions,
			Observable.combineLatest(
				input.checkbox1_selected.do(onNext: checkbox1_status.accept),
				input.checkbox2_selected.do(onNext: checkbox2_status.accept),
				input.checkbox3_selected.do(onNext: checkbox3_status.accept),
				input.checkbox4_selected.do(onNext: checkbox4_status.accept)
			)
		)
		.map { (questions, checkboxes) -> Bool in
			let season1To3IsEmpty = questions.filter { $0.season == 1 }.isEmpty
			let season4IsEmpty = questions.filter { $0.season == 2 }.isEmpty
			let season5IsEmpty = questions.filter { $0.season == 3 }.isEmpty
			let season6To9IsEmpty = questions.filter { $0.season == 4 }.isEmpty
			return
				!(!checkboxes.0 && !checkboxes.1 && !checkboxes.2 && !checkboxes.3) &&
				!(season1To3IsEmpty && checkboxes.0) &&
				!(season4IsEmpty && checkboxes.1) &&
				!(season5IsEmpty && checkboxes.2) &&
				!(season6To9IsEmpty && checkboxes.3)
		}
		let set_nickname = input.user_nickname
			.do(onNext: { username in
				guard let username else { return }
				Auth.auth().signInAnonymously { (authResult, error) in
					guard error == nil else { return }
					guard let currentUser = Auth.auth().currentUser else { return }
					let uid = currentUser.uid
					let userData: [String: Any] = ["username": username]
					self.ref.child("users").child(uid).setValue(userData) { (error, _) in }
				}
			})
			.map { $0 == nil }
		
		let filteredQuestions = input.play
			.flatMap { questions }
			.map { (questions) -> [Question] in
				questions.filter { (question) -> Bool in
					return
						(self.checkbox1_status.value && question.season == 1) ||
						(self.checkbox2_status.value && question.season == 2) ||
						(self.checkbox3_status.value && question.season == 3) ||
						(self.checkbox4_status.value && question.season == 4)
				}
			}
		return Output(
			set_nickname: set_nickname.asDriver(onErrorJustReturn: true),
			can_play: can_play.asDriver(onErrorJustReturn: false),
			questions: filteredQuestions.asDriver(onErrorJustReturn: []),
			best_score: .just(0)
		)
	}
}
