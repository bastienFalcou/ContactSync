//
//  ViewControllerModel.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import ReactiveSwift
import DataSource
import Result

final class EntranceViewModel: NSObject {
	var dataSource = MutableProperty<DataSource>(EmptyDataSource())
	let disposable = CompositeDisposable()

	let syncedPhoneContacts = MutableProperty<[PhoneContact]>([])

	deinit {
		self.disposable.dispose()
	}

	override init() {
		super.init()

		self.disposable += self.syncedPhoneContacts.producer.startWithValues { [weak self] syncedPhoneContacts in
			self?.dataSource.value = StaticDataSource(items: syncedPhoneContacts.map { ContactTableViewCellModel(contact: $0) })
		}

		self.updateSyncedPhoneContacts()
	}

	func syncContacts() {
		ContactFetcher.shared.syncContactsAction.apply().observe(on: UIScheduler()).startWithResult { [weak self] result in
			self?.updateSyncedPhoneContacts()
		}
	}

	func removeAllContacts() {
		try! RealmManager.shared.realm.write {
			let allContacts = RealmManager.shared.realm.objects(PhoneContact.self)
			RealmManager.shared.realm.delete(allContacts)
			self.updateSyncedPhoneContacts()
		}
	}

	// MARK: - Private

	fileprivate func updateSyncedPhoneContacts() {
		self.syncedPhoneContacts.value = PhoneContact.allPhoneContacts()
	}

	fileprivate func addTestUser() {
		let phoneContact = PhoneContact()
		phoneContact.phoneNumber = "+33648164683"
		phoneContact.username = "bastienFalcou"

		try! RealmManager.shared.realm.write {
			RealmManager.shared.realm.add(phoneContact)
		}
	}
}
