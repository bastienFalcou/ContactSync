//
//  SyncProtocol.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/12/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation
import RealmSwift

protocol SyncProtocol: class {
	static func uniqueObject(for id: Any, in realm: Realm?) -> Self
}
