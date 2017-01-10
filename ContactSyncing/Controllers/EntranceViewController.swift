//
//  ViewController.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/6/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import ReactiveSwift
import DataSource

final class EntranceViewController: UIViewController {
	@IBOutlet private var tableView: UITableView!

	let viewModel = EntranceViewModel()
	let tableDataSource = TableViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()

		ContactFetcher.shared.requestContactsPermission()

		self.tableDataSource.reuseIdentifierForItem = { _ in
			return ContactTableViewCellModel.reuseIdentifier
		}

		self.tableView.dataSource = self.tableDataSource
		self.tableView.delegate = self
		self.tableDataSource.tableView = self.tableView

		self.tableDataSource.dataSource.innerDataSource <~ self.viewModel.dataSource
	}

	@IBAction func removeAllContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.removeAllContacts()
	}

	@IBAction func syncContactsButtonTapped(_ sender: AnyObject) {
		self.viewModel.syncContacts()
	}
}

extension EntranceViewController: UITableViewDelegate {

}
