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

public extension NSObjectProtocol {
    var className: String {
        let `class` = type(of: self)
        return String(describing: `class`)
    }

    static var className: String {
        return String(describing: self)
    }
}

extension NSObject {
    public func withValueChange(for key: String, change: () -> Void) -> Void {
        willChangeValue(forKey: key)

        change()

        didChangeValue(forKey: key)
    }
}
