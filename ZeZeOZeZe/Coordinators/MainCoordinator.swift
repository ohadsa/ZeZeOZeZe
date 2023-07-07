//
//  MainCoordinator.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
	var navigationController: UINavigationController
	var children: [Coordinator]

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		navigationController.setNavigationBarHidden(true, animated: false)
		self.children = [Coordinator]()
	}
	func start() {
		let viewController = MainViewController(nibName: "MainViewController", bundle: .main)
		viewController.coordinator = self
		self.navigationController.pushViewController(viewController, animated: true)
	}
	func startGame(with questions: [Question]) {
		let viewController = GameViewController(nibName: "GameViewController", bundle: .main)
		viewController.coordinator = self
		viewController.viewModel = GameViewModel(questions: questions)
		self.navigationController.pushViewController(viewController, animated: true)
	}
}
