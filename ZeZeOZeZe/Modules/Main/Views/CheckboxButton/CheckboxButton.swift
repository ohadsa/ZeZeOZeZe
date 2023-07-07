//
//  CheckboxButton.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CheckboxButtonDelegate: AnyObject {
	func onClick(_ checkboxButton: CheckboxButton)
}

@IBDesignable
class CheckboxButton: UIControl {

	weak var delegate: CheckboxButtonDelegate?

	private var selectedRelay = BehaviorRelay(value: false)
	override var isSelected: Bool { didSet { selectedRelay.accept(isSelected) } }
	var isSelectedObservable: Observable<Bool> { selectedRelay.asObservable() }

	private lazy var animator = UIViewPropertyAnimator()
	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "CheckboxButton", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.backgroundColor = .clear
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return containerView
	}()

	@IBOutlet private var outlineView: UIView!
	@IBOutlet private var iconImageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!

	@IBInspectable var checkImage: UIImage?
	@IBInspectable var clearImage: UIImage? { didSet { self.iconImageView.image = clearImage } }
	@IBInspectable var title: String? { didSet { self.titleLabel.text = title } }
	@IBInspectable var textColor: UIColor? { didSet { self.titleLabel.textColor = textColor } }

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
		self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
		self.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
		self.addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
	}

}

extension CheckboxButton {
	@objc func touchUpInside() {
		self.isSelected.toggle()
		self.iconImageView.image = isSelected ? checkImage : clearImage
		self.delegate?.onClick(self)
	}
	@objc func touchUp() {
		self.animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: { self.outlineView.backgroundColor = .white })
		self.animator.startAnimation()
	}
	@objc func touchDown() {
		self.animator.stopAnimation(true)
		self.outlineView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
	}
}
