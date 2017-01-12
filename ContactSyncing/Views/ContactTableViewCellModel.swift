//
//  ContactTableViewModel.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation

struct ContactTableViewCellModel {
	static var reuseIdentifier: String {
		return String(describing: ContactTableViewCell.self)
	}

	let contact: PhoneContact
}
