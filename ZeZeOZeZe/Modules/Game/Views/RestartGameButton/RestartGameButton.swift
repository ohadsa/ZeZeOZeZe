//
//  RestartGameButton.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol RestartGameButtonDelegate: AnyObject {
	func onClick(_ checkboxButton: CheckboxButton)
}

@IBDesignable
class RestartGameButton: UIControl {

	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var title: UILabel!

	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "RestartGameButton", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return containerView
	}()

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
		self.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
		self.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
	}
}

extension RestartGameButton {
	@objc func touchUp() {
		UIView.transition(with: self.title, duration: 0.25, options: .transitionCrossDissolve) {
			self.title.textColor = .white
			self.imageView.tintColor = .white
		}
	}
	@objc func touchDown() {
		self.imageView.tintColor = UIColor.white.withAlphaComponent(0.1)
		self.title.textColor = UIColor.white.withAlphaComponent(0.1)
	}
}

extension Reactive where Base: RestartGameButton {
	var tap: ControlEvent<Void> {
		self.base.rx.controlEvent(.touchUpInside)
	}
}
