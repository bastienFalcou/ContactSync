//
//  PhoneContact+Sync.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/12/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

extension PhoneContact: SyncProtocol {
	static func uniqueObject(for id: Any, in realm: Realm?) -> PhoneContact {
		let phoneNumber: String = id as! String
		let realm = realm ?? RealmManager.shared.realm

		if let existingObject = realm.object(ofType: PhoneContact.self, forPrimaryKey: phoneNumber) {
			return existingObject
		} else {
			let newObject = PhoneContact()
			newObject.phoneNumber = phoneNumber
			return newObject
		}
	}
}
