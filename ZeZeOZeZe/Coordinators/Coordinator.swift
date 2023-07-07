//
//  Coordinator.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import UIKit

protocol Coordinator {
	var navigationController: UINavigationController { get set }
	var children: [Coordinator] { get set }
	func start()
}
