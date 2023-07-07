//
//  GameHeaderView.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class GameHeaderView: UIView {

	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "GameHeaderView", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.backgroundColor = .clear
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return containerView
	}()

	@IBOutlet fileprivate var back_button: UIButton!
	@IBOutlet fileprivate var timer_label: UILabel!
	@IBOutlet fileprivate var score_label: UILabel!

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
		back_button.layer.masksToBounds = true
		back_button.layer.cornerRadius = min(back_button.frame.width, back_button.frame.height) / 2
	}
}

extension Reactive where Base: GameHeaderView {
	var back_tapped: Observable<Void> { base.back_button.rx.tap.asObservable() }
	var time: Binder<String> {
		Binder<String>(base) { base, time in
			base.timer_label.text = time
		}
	}
	var score: Binder<String> {
		Binder<String>(base) { base, score in
			base.score_label.text = score
		}
	}
}
