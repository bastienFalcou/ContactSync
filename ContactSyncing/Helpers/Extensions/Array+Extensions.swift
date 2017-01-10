//
//  Array+Extensions.swift
//  ContactSyncing
//
//  Created by Bastien Falcou on 1/10/17.
//  Copyright © 2017 Bastien Falcou. All rights reserved.
//

import Foundation

extension Array {
	func chunk(_ chunkSize: Int) -> [[Element]] {
		return stride(from: 0, to: self.count, by: chunkSize).map({ (startIndex) -> [Element] in
			let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
			return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
		})
	}
}
