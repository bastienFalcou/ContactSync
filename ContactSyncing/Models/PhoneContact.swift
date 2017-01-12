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

	static func substractObsoleteLocalContacts(with contacts: [PhoneContact], realm: Realm = RealmManager.shared.realm) {
		let allLocalContacts: Set<PhoneContact> = Set(realm.objects(PhoneContact.self))
		let removedContacts = allLocalContacts.subtracting(Set(contacts))

		do {
			try realm.write {
				removedContacts.forEach { realm.delete($0) }
			}
			realm.refresh()
		} catch {
			print("PhoneContact: failed to sync local database")
		}
	}
}
