//
//  ViewController.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import RealmSwift

final class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		let phoneContact = PhoneContact()
		phoneContact.phoneNumber = "+33648164683"
		phoneContact.username = "bastienFalcou"

		try! RealmManager.shared.realm.write {
			RealmManager.shared.realm.add(phoneContact)
		}

		let phoneContacts = RealmManager.shared.realm.objects(PhoneContact.self)
		print(phoneContacts.description)
	}
}
