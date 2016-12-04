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


import ObjectiveC.runtime

public final class ObjectAssociationKey<T> {
    init() {}
}

public func withAssociatedObject<T: NSObjectProtocol, Result>(_ object: Any, key: inout ObjectAssociationKey<T> , _ body: (_ object: T?) throws -> Result) rethrows -> Result {
    let associated = withUnsafePointer(to: &key) { return objc_getAssociatedObject(object, $0) as? T }

    return try body(associated)
}

extension NSObjectProtocol {
    public func associate<T: NSObjectProtocol>(object: T?, for key: inout ObjectAssociationKey<T>, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        withUnsafePointer(to: &key) { objc_setAssociatedObject(self, $0, object, policy) }
    }

    public func getAssociated<T: NSObjectProtocol>(for key: inout ObjectAssociationKey<T>) -> T? {
        return withUnsafePointer(to: &key) { return objc_getAssociatedObject(self, $0) } as? T
    }
}
