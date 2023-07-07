//
//  GameOverView.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class GameOverView: UIView {

	@IBOutlet fileprivate var title_imageView: UIImageView!
	@IBOutlet fileprivate var score_label: UILabel!
	@IBOutlet fileprivate var score_title_label: UILabel!
	@IBOutlet fileprivate var record_background_view: UIView!
	@IBOutlet fileprivate var record_label: UILabel!
	@IBOutlet fileprivate var restart_game_button: RestartGameButton!

	private lazy var gradientLayer: CAGradientLayer = {
		let layer = CAGradientLayer()
		layer.colors = [#colorLiteral(red: 1, green: 0.831372549, blue: 0.2235294118, alpha: 1).cgColor, UIColor.white.cgColor]
		layer.startPoint = CGPoint(x: 1, y: 1)
		layer.endPoint = CGPoint(x: 0, y: 1)
		return layer
	}()

	private lazy var containerView: UIView = {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "GameOverView", bundle: bundle)
		let containerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		containerView.frame = bounds
		containerView.backgroundColor = .white
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
		self.record_label.backgroundColor = .clear
		self.record_background_view.layer.insertSublayer(self.gradientLayer, at: 0)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.gradientLayer.frame = self.record_background_view.bounds
	}

}

extension Reactive where Base: GameOverView {
	var status: Binder<GameOverStatusEnum> {
		Binder<GameOverStatusEnum>(base) { base, status in
			base.title_imageView.image = {
				switch status {
				case .all_questions_answered: return #imageLiteral(resourceName: "im_allsolved")
				case .time_out: return #imageLiteral(resourceName: "im_timeout")
				default: return nil
				}
			}()
		}
	}
	var score: Binder<String> {
		Binder<String>(base) { base, score in
			base.score_label.text = score
		}
	}
	var record_score: Binder<String> {
		Binder<String>(base) { base, record_score in
			base.record_label.text = record_score
		}
	}
	var replay_tap: ControlEvent<Void> {
		self.base.restart_game_button.rx.tap
	}
}
