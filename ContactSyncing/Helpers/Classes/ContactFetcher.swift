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

	let didAnswerContactsPermissionSignal: Signal<Void, NSError>
	private let didAnswerContactsPermissionObserver: Observer<Void, NSError>

	internal let areContactsActive = MutableProperty(false)

	override init() {
		(self.didAnswerContactsPermissionSignal, self.didAnswerContactsPermissionObserver) = Signal.pipe()

		super.init()

		self.syncContactsAction = Action(self.syncLocalAddressBook)
	}

	func requestContactsPermission() {
		func notify() {
			self.updateAuthorizationStatusIfNeeded()
			self.didAnswerContactsPermissionObserver.send(value: ())
		}
		self.phoneContactFetcher.authorize(success: {
			notify()
		}) { error in
			notify()
		}
	}

	// PRAGMA: - private

	private func updateAuthorizationStatusIfNeeded() {
		let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
		self.areContactsActive.value = authorizationStatus == .authorized
	}

	private func syncLocalAddressBook() -> SignalProducer<[PhoneContact], NSError> {
		return SignalProducer { sink, disposable in
			self.phoneContactFetcher.fetchContacts(for: [.GivenName, .FamilyName, .Phone], success: { contacts in
				RealmManager.shared.performInBackground(backgroundAction: { backgroundRealm in
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

						sink.send(value: contactEntities)
						sink.sendCompleted()
					} catch {
						print("Contacts: failed to save synced contacts: \(error)")
						sink.send(error: error as NSError)
					}
				})
			}) { error in
				print("Contacts: failed to save synced contacts: \(error)")
				sink.send(error: error as! NSError)
			}
		}
	}

	/*
	private func syncRemoteAddressBook() -> SignalProducer<[Contact], NSError> {
		print("Contacts: number local contacts before syncing: \(PhoneContact.allPhoneContacts.count)")

		return SignalProducer { sink, disposable in
			self.syncLocalAddressBook().startWithNext { contacts in
				RealmManager.shared.performInBackground(backgroundAction: { backgroundContext in
					do {
						let contacts = try contacts.map { try $0.inContext(backgroundContext) }
						Contact.syncLocalContacts(contacts, context: backgroundContext)
						try backgroundContext.save()
						LogTrace("Contacts: number local contacts after syncing: \(Contact.allObjects(inContext: backgroundContext).count)")

						Contact.syncRemoteContacts(Contact.allObjects(inContext: backgroundContext) as! [Contact]).start(sink)
					} catch {
						LogError("Contacts: failed to save synced contacts: \(error)")
						sink.sendFailed(error as NSError)
					}
				}
			}
		}
	}*/
}
