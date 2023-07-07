//
//  GettingStartedView.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class GettingStartedView: UIView {

	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "GettingStartedView", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.backgroundColor = .clear
		containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		return containerView
	}()

	@IBOutlet fileprivate var timer_label: UILabel!

	@IBInspectable var start_timer_from: Int = 3 { didSet { timer_label.text = "\(start_timer_from)" } }

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

}
extension Reactive where Base: GettingStartedView {
	var time: Binder<String> {
		Binder<String>(base) { (base, time) in
			base.timer_label.text = time
		}
	}
}
