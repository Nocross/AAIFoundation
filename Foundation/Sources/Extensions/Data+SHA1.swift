//
//  String+SHA1.swift
//  UIKit
//
//  Created by Leonid Basov on 01/06/2019.
//  Copyright © 2019 Andrey Ilskiy. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
	public var sha1: String {
		let data = self
		var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
		data.withUnsafeBytes {
			_ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
		}
		let hexBytes = digest.map { String(format: "%02hhx", $0) }
		return hexBytes.joined()
	}
}
