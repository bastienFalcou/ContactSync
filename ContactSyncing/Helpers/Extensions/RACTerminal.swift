//
//  RACTerminal.swift
//  Owners
//
//  Created by Ravindra Soni on 25/05/2016.
//  Copyright © 2016 Fueled. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import DataSource
import Result

extension Reactive where Base: NSObject {
	func target<U>(action: @escaping (Base, U) -> Void) -> BindingTarget<U> {
		return BindingTarget(on: ImmediateScheduler(), lifetime: lifetime) {
			[weak base = self.base] value in
			if let base = base {
				action(base, value)
			}
		}
	}
}

extension Reactive where Base: UIViewController {
	var title: BindingTarget<String> {
		return target { $0.title = $1 }
	}
}

extension Reactive where Base: UISwitch {
	var isOn: BindingTarget<Bool> {
		return target { $0.isOn = $1 }
	}
}

extension Reactive where Base: UIView {
	var isHidden: BindingTarget<Bool> {
		return target { $0.isHidden = $1 }
	}

	var backgroundColor: BindingTarget<UIColor> {
		return target { $0.backgroundColor = $1 }
	}

	var borderWidth: BindingTarget<CGFloat> {
		return target { $0.layer.borderWidth = $1 }
	}
}

extension Reactive where Base: UILabel {
	var textColor: BindingTarget<UIColor> {
		return target { $0.textColor = $1 }
	}
	var attributedText: BindingTarget<NSAttributedString> {
		return target { $0.attributedText = $1 }
	}
}

extension Reactive where Base: UITextField {
	var text: BindingTarget<String> {
		return target { $0.text = $1 }
	}
	var placeholder: BindingTarget<String> {
		return target { $0.placeholder = $1 }
	}
}

extension Reactive where Base: UISearchBar {
	var text: BindingTarget<String> {
		return target { $0.text = $1 }
	}
}

extension Reactive where Base: UINavigationBar {
	var barTintColor: BindingTarget<UIColor> {
		return target { $0.barTintColor = $1 }
	}
}

extension Reactive where Base: UIControl {
	var isSelected: BindingTarget<Bool> {
		return target { $0.isSelected = $1 }
	}
}

extension Reactive where Base: UIBarButtonItem {
	var isEnabled: BindingTarget<Bool> {
		return target { $0.isEnabled = $1 }
	}
	var title: BindingTarget<String> {
		return target { $0.title = $1 }
	}
}

extension Reactive where Base: UISegmentedControl {
	var selectedSegmentIndex: BindingTarget<Int> {
		return target { $0.selectedSegmentIndex = $1 }
	}
}

extension Reactive where Base: UITableView {
	var setEditing: BindingTarget<Bool> {
		return target { $0.setEditing($1, animated: true) }
	}
	var showSeparator: BindingTarget<Bool> {
		return target { $0.separatorStyle = $1 ? .singleLine : .none }
	}
}

extension Reactive where Base: UICollectionView {
	var reloadData: BindingTarget<Bool> {
		return target { if $1 { $0.reloadData() } }
	}
}

extension Reactive where Base: UITableViewCell {
	var setEditing: BindingTarget<(editing: Bool, animated: Bool)> {
		return target { $0.setEditing($1.0, animated: $1.1) }
	}
}
