/*
    Copyright (c) 2016 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */


import Foundation.NSData

extension String {
    public mutating func replaceCharacter(atIndex index: String.Index, with character: Character) {
        let range = index..<self.index(after: index)
        self.replaceSubrange(range, with: [character])
    }
}

//public extension String.CharacterView  {
//    func character(fromStart offset: UInt) -> Character? {
//        var result: Character? = nil
//
//        if let idx = self.index(startIndex, offsetBy: numericCast(offset), limitedBy: endIndex) {
//            result = self[idx]
//        }
//
//        return result
//    }
//
//    func character(fromEnd offset: UInt) -> Character? {
//        var result: Character? = nil
//
//        if let idx = self.index(endIndex, offsetBy: -1 * numericCast(offset), limitedBy: startIndex) {
//            result = self[idx]
//        }
//
//        return result
//    }
//}

//MARK: -

extension String {
    public func base64EncodedString(using encoding: String.Encoding, allowLossyConversion lossy: Bool = false, base64Options options: Data.Base64EncodingOptions = []) -> String? {
        var result: String? = nil

        if !self.isEmpty && self.canBeConverted(to: encoding){
            let data = self.data(using: encoding, allowLossyConversion: lossy)
            result = data?.base64EncodedString(options: options)
        }

        return result
    }

    public init?(base64Encoded string: String, options: Data.Base64DecodingOptions = [], using encoding: String.Encoding) {
        if let data = Data(base64Encoded: string) {
            self.init(data: data, encoding: encoding)
        } else {
            return nil
        }
    }
}

//public extension String {
//    public func md5StringWithEncoding(encoding: String.Encoding) -> String? {
//        guard !self.isEmpty  && self.canBeConverted(to: encoding) else {
//            return nil
//        }
//
//        let digestLenght = CC_MD5_DIGEST_LENGTH
//        
//    }
//}
