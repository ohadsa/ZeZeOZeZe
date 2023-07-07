//
//  QuestionView.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class QuestionView: UIView {

	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "QuestionView", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.backgroundColor = .clear
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return containerView
	}()

	@IBOutlet fileprivate var question_label: UILabel!

	@IBOutlet fileprivate var answer1_button: UIButton!
	@IBOutlet fileprivate var answer2_button: UIButton!
	@IBOutlet fileprivate var answer3_button: UIButton!
	@IBOutlet fileprivate var answer4_button: UIButton!

	var question: Question! {
		didSet {
			self.question_label.text = question?.question
			let answers = [question?.answer1, question?.answer2, question?.answer3, question?.answer4].shuffled()
			self.answer1_button.setTitle(answers[0], for: .normal)
			self.answer2_button.setTitle(answers[1], for: .normal)
			self.answer3_button.setTitle(answers[2], for: .normal)
			self.answer4_button.setTitle(answers[3], for: .normal)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupViews()
	}

	func setupViews() {
		self.addSubview(containerView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutIfNeeded()
		[answer1_button, answer2_button, answer3_button, answer4_button].forEach {
			guard let button = $0 else { return }
			button.layer.borderColor = #colorLiteral(red: 0.8980392157, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
			button.layer.borderWidth = 1
			button.layer.masksToBounds = true
			button.layer.cornerRadius = min(button.bounds.width, button.bounds.height) / 2
		}
	}
}

extension Reactive where Base: QuestionView {
	var question: Binder<Question> {
		Binder<Question>(base) { (base, question) in
			base.question = question
		}
	}
	var answer_tapped: Observable<(UIButton?, Question, Bool)> {
		Observable<UIButton?>
			.merge(
				self.base.answer1_button.rx.tap.map { self.base.answer1_button },
				self.base.answer2_button.rx.tap.map { self.base.answer2_button },
				self.base.answer3_button.rx.tap.map { self.base.answer3_button },
				self.base.answer4_button.rx.tap.map { self.base.answer4_button }
			)
			.map { ($0, self.base.question, $0?.titleLabel?.text == self.base.question.answer1) }
	}
}
