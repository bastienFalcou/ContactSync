//
//  User.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

final class PhoneContact: Object {
	// Properties
	dynamic var phoneNumber: String = ""
	dynamic var username: String = ""

	// Relationships
	fileprivate let creditCards = List<CreditCard>()

	override static func primaryKey() -> String? {
		return "phoneNumber"
	}

	static func allPhoneContacts(in realm: Realm = RealmManager.shared.realm) -> [PhoneContact] {
		return Array(realm.objects(PhoneContact.self))
	}
}
