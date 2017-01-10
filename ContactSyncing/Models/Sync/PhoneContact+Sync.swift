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

func Y<T, R>(_ function: @escaping (@escaping (T) -> R) -> ((T) -> R) ) -> ((T) -> R) {
	return { argument in function(Y(function))(argument) }
}

extension PhoneContact {
	@nonobjc static let apiContactsSyncChunkLimit: Int = 2

	static func syncRemoteContacts(_ localContacts: [PhoneContact])
		-> SignalProducer<[PhoneContact], NSError>
	{
		return SignalProducer { sink, disposable in
			let chunks = localContacts.chunk(PhoneContact.apiContactsSyncChunkLimit)
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

	fileprivate static func syncContactsChunkInternal(_ chunck: [PhoneContact])
		-> SignalProducer<[PhoneContact], NSError>
	{
		return SignalProducer { sink, _ in
			RealmManager.shared.performInBackground { backgroundRealm in
				// Simulate API call that would take in parameters all phone numbers of the chunck contacts, parse JSON from
				// server and update the PhoneContact objects accordingly, before returning everything.
				sleep(UInt32(3.0))

				sink.send(value: chunck)
				sink.sendCompleted()
			}
		}
	}
}
