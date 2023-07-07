//
//  QuestionsService.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol QuestionsService {
	func getQuestions() -> Observable<[Question]>
}
