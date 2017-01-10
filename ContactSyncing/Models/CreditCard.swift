//
//  CreditCard.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

final class CreditCard: Object {
	// Properties
	dynamic var creditCardNumber: String = ""
	let numberTransactions = RealmOptional<Int>()

	// Ignored Properties
	var hasBeenUsed: Bool = false

	// Relationships
	let owner = LinkingObjects(fromType: PhoneContact.self,	property: "creditCards")

	override static func ignoredProperties() -> [String] {
		return ["hasBeenUsed"]
	}
}
