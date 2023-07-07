//
//  StorageHandler.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import FirebaseCore
import FirebaseDatabase

class StorageHandler {

	var nickname: String? {
		get { UserDefaults.standard.string(forKey: "nickname") }
		set { UserDefaults.standard.set(newValue, forKey: "nickname") }
	}

	var nickname_observable: Observable<String?> {
		UserDefaults.standard.rx.observe(String.self, "nickname")
	}

	var best_score: Int {
		get { UserDefaults.standard.integer(forKey: "best_score") }
		set { UserDefaults.standard.set(newValue, forKey: "best_score") }
	}

	var best_score_observable: Observable<Int?> {
		UserDefaults.standard.rx.observe(Int.self, "best_score")
	}

	private init() { }

	static let shared = StorageHandler()

}
