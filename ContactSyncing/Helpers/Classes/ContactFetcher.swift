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

	fileprivate let phoneContactFetcher = PhoneContactFetcher()
	var syncContactsAction: Action<Void, [PhoneContact], NSError>!

	let didAnswerContactsPermissionSignal: Signal<Void, NSError>
	fileprivate let didAnswerContactsPermissionObserver: Observer<Void, NSError>

	internal let areContactsActive = MutableProperty(false)

	override init() {
		(self.didAnswerContactsPermissionSignal, self.didAnswerContactsPermissionObserver) = Signal.pipe()

		super.init()

		self.syncContactsAction = Action(self.syncRemoteAddressBook)
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

	fileprivate func updateAuthorizationStatusIfNeeded() {
		let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
		self.areContactsActive.value = authorizationStatus == .authorized
	}

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
				if let error = result.error {
					sink.send(error: error as NSError)
					return
				}

				RealmManager.shared.performInBackground { backgroundRealm in
					do {
						let localContacts: [PhoneContact] = result.value!.map { id in
							return backgroundRealm.object(ofType: PhoneContact.self, forPrimaryKey: id)!
						}

						//Contact.syncLocalContacts(localContacts, context: backgroundContext)
						print("Contacts: number local contacts after syncing: \(PhoneContact.allPhoneContacts(in: backgroundRealm).count)")

						PhoneContact.syncRemoteContacts(localContacts).start(sink)
					} catch {
						print("Contacts: failed to save synced contacts: \(error)")
						sink.send(error: error as NSError)
					}
				}
			}
		}
	}
}
