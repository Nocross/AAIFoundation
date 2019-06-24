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

import Foundation

extension String {
    public mutating func replaceCharacter(atIndex index: String.Index, with character: Character) {
        let range = index..<self.index(after: index)
        self.replaceSubrange(range, with: [character])
    }
}

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

//MARK: -

extension String.Encoding {
    init?(ianaCharSet name: String) {
        let encoding = CFStringConvertIANACharSetNameToEncoding(name as CFString)
        
        self.init(cf: encoding)
    }
    
    init(cf encoding: CFStringEncoding) {
        let nsencoding = CFStringConvertEncodingToNSStringEncoding(encoding)
        
        self.init(rawValue: nsencoding)
    }
}
