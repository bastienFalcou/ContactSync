//
//  PhoneContactsFetcher.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift
import EthanolContacts
import ReactiveSwift
import Contacts

final class ContactFetcher: NSObject {
	static var shared = ContactFetcher()

	private let phoneContactFetcher = PhoneContactFetcher()
	var syncContactsAction: Action<Void, [PhoneContact], NSError>!

	private let areContactsActive = MutableProperty(false)

	override init() {
		super.init()
		self.syncContactsAction = Action(self.syncRemoteAddressBook)
	}

	func requestContactsPermission() {
		self.phoneContactFetcher.authorize(success: {
			print("Contacts: access granted")
		}) { error in
			print("Contacts: access denied")
		}
	}

	// PRAGMA: - private

	fileprivate func syncLocalAddressBook() -> SignalProducer<[String], NSError> {
		return SignalProducer { sink, disposable in
			self.phoneContactFetcher.fetchContacts(for: [.GivenName, .FamilyName, .Phone], success: { contacts in
				RealmManager.shared.performInBackground { backgroundRealm in
					var contactEntities: [PhoneContact] = []

					for contact in contacts where contact.phone != nil && !contact.phone!.isEmpty {
						let phoneNumber = contact.phone!.first!

						//let contactEntity = Contact.existingObject(withKey: phoneNumber, forKeyFieldName: "phoneNumber", inContext: backgroundContext)
							//?? Contact.newInstance(inContext: backgroundContext)

						let contactEntity = PhoneContact()

						contactEntity.phoneNumber = phoneNumber
						contactEntity.username = contact.familyName.isEmpty ? "\(contact.givenName)" : "\(contact.givenName) \(contact.familyName)"
						contactEntities.append(contactEntity)
					}
					do {
						try backgroundRealm.write {
							backgroundRealm.add(contactEntities)
						}
						backgroundRealm.refresh()

						sink.send(value: contactEntities.map { $0.phoneNumber })
						sink.sendCompleted()
					} catch {
						print("Contacts: failed to save synced contacts: \(error)")
						sink.send(error: error as NSError)
					}
				}
			}) { error in
				print("Contacts: failed to save synced contacts: \(error)")
				sink.send(error: error as! NSError)
			}
		}
	}

	fileprivate func syncRemoteAddressBook() -> SignalProducer<[PhoneContact], NSError> {
		print("Contacts: number local contacts before syncing: \(PhoneContact.allPhoneContacts().count)")

		return SignalProducer { sink, disposable in
			self.syncLocalAddressBook().startWithResult { result in
				switch result {
				case .success(let result):
					RealmManager.shared.performInBackground { backgroundRealm in
						//Contact.syncLocalContacts(localContacts, context: backgroundContext)
						print("Contacts: number local contacts after syncing: \(PhoneContact.allPhoneContacts(in: backgroundRealm).count)")

						PhoneContact.syncRemoteContacts(for: result).observe(on: UIScheduler()).start(sink)
					}
				case .failure(let error):
					sink.send(error: error as NSError)
				}
			}
		}
	}
}
