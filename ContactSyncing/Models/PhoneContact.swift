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
	private let creditCards = List<CreditCard>()

	static var allPhoneContacts: [PhoneContact] {
		return Array(RealmManager.shared.realm.objects(PhoneContact.self))
	}
}
