//
//  ContactTableViewCell.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import UIKit
import DataSource
import ReactiveSwift

final class ContactTableViewCell: TableViewCell {
	@IBOutlet fileprivate var contactNameLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		let model = self.cellModel
			.producer
			.map { $0 as? ContactTableViewCellModel }
			.skipNil()

		self.reactive.target { $0.configure(with: $1) } <~ model
	}

	fileprivate func configure(with cellModel: ContactTableViewCellModel) {
		self.contactNameLabel.text = cellModel.contact.username
	}
}
