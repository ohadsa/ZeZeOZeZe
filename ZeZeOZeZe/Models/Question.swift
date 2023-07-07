//
//  Question.swift
//  ZeZeOZeZe
//
//  Created by Ohad Saada on 02/07/2023.
//  Copyright © 2023 Ohad Saada. All rights reserved.
//

import Foundation

struct Question: Codable {
	let question: String
	let answer1, answer2, answer3, answer4: String
	let id: Int
	let season: Int
	let solved: Int
	enum CodingKeys: String, CodingKey {
		case question
		case answer1 = "a1"
		case answer2 = "a2"
		case answer3 = "a3"
		case answer4 = "a4"
		case id
		case season
		case solved
	}
}
