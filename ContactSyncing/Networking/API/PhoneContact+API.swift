//
//  PhoneContact+Sync.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import ReactiveSwift

// Recursive Y-combinator functions inspired from:
// https://xiliangchen.wordpress.com/2014/08/04/recursive-closure-and-y-combinator-in-swift/

func Y<T, R>(_ function: @escaping (@escaping (T) -> R) -> ((T) -> R)) -> ((T) -> R) {
	return { argument in function(Y(function))(argument) }
}

extension PhoneContact {
	static func syncRemoteContacts(for phoneNumbers: [String])
		-> SignalProducer<[PhoneContact], NSError>
	{
		return SignalProducer { sink, disposable in
			let chunks = phoneNumbers.chunk(RemoteSyncingConfigurations.apiContactsSyncChunkLimit)
			var chunkIndex = 0
			let	chunkCount = chunks.count

			let syncChunk = Y {
				function in {
					if chunkIndex >= chunkCount {
						sink.sendCompleted()
						return
					}

					self.syncContactsChunkInternal(chunks[chunkIndex]).on(failed: { error in
						sink.send(error: error)
						return
					}, value: { contacts in
						sink.send(value: contacts)
						chunkIndex += 1
						function()
					}).start()
				}
			}
			syncChunk()
		}
	}

	fileprivate static func syncContactsChunkInternal(_ chunck: [String])
		-> SignalProducer<[PhoneContact], NSError>
	{
		return SignalProducer { sink, _ in
			RealmManager.shared.performInBackground { backgroundRealm in
				// Simulate API call that would take in parameters all thread safe contacts (including most 
				// likely their phone numbers to use as parameter of the call) of the chunck contacts, parse
				// JSON from server and update the PhoneContact objects accordingly, before returning everything.
				sleep(UInt32(RemoteSyncingConfigurations.apiContactsSyncCallDuration))

				DispatchQueue.main.async {
					let contacts: [PhoneContact] = chunck.map { id in
						return RealmManager.shared.realm.object(ofType: PhoneContact.self, forPrimaryKey: id)!
					}
					sink.send(value: contacts)
					sink.sendCompleted()
				}
			}
		}
	}
}
