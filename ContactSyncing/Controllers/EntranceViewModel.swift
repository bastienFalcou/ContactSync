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

	var syncingDisposable: Disposable? {
		willSet {
			self.syncingDisposable?.dispose()
		}
	}

	let syncedPhoneContacts = MutableProperty<[PhoneContact]>([])
	let syncingProgress = MutableProperty(0.0)
	let isSyncing = MutableProperty(false)

	deinit {
		self.disposable.dispose()
	}

	override init() {
		super.init()

		self.disposable += self.isSyncing <~ ContactFetcher.shared.syncContactsAction.isExecuting
		self.disposable += self.syncedPhoneContacts.producer.startWithValues { [weak self] syncedPhoneContacts in
			self?.dataSource.value = StaticDataSource(items: syncedPhoneContacts.map { ContactTableViewCellModel(contact: $0) })

			let localPhoneContactsCount = PhoneContact.allPhoneContacts().count
			self?.syncingProgress.value = localPhoneContactsCount == 0 ? 0.0 : Double(syncedPhoneContacts.count) / Double(localPhoneContactsCount)
		}
	}

	func syncContacts() {
		self.syncingDisposable = ContactFetcher.shared.syncContactsAction.apply().startWithResult { [weak self] result in
			if let syncedContacts = result.value {
				syncedContacts.forEach { self?.syncedPhoneContacts.value.append($0) }
			}
		}
	}

	func removeAllContacts() {
		self.syncingDisposable?.dispose()

		do {
			try RealmManager.shared.realm.write {
				RealmManager.shared.realm.delete(RealmManager.shared.realm.objects(PhoneContact.self))
				self.syncedPhoneContacts.value = PhoneContact.allPhoneContacts()
			}
		} catch {
			print("Entrance View Model: could not remove all contacts")
		}
	}
}
