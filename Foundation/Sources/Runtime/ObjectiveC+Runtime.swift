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

public struct ObjectiveC {
    private init() {}

    public struct Runtime {
        private init() {}
    }
}

extension ObjectiveC.Runtime {
    public final class ObjectAssociationKey {
        init() {}
    }

    public static func associate<T: AnyObject>(object: T?, to otherObject: AnyObject, for key: ObjectAssociationKey, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        let keyPtr = Unmanaged.passUnretained(key).toOpaque()
        objc_setAssociatedObject(otherObject, keyPtr, object ?? nil, policy)
    }

    public static func getAssociated<T: AnyObject>(to object: AnyObject, for key: ObjectAssociationKey) -> T? {
        let keyPtr = Unmanaged.passUnretained(key).toOpaque()
        return objc_getAssociatedObject(object, keyPtr) as? T
    }

    public static func removeAssociatedObjects(from object: Any) {
        objc_removeAssociatedObjects(object)
    }

    public static func withAssociated<T: AnyObject, Result>(to object: AnyObject, for key: ObjectAssociationKey, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ body: (_ object: inout T?) throws -> Result) rethrows -> Result {
        let keyPtr = Unmanaged.passUnretained(key).toOpaque()
        var associated = objc_getAssociatedObject(object, keyPtr) as? T

        let result = try body(&associated)

        objc_setAssociatedObject(object, keyPtr, associated ?? nil, policy)

        return result
    }
}

extension NSObjectProtocol {
    public typealias ObjectAssociationKey = ObjectiveC.Runtime.ObjectAssociationKey

    public func associate<T: AnyObject>(object: T?, for key: ObjectAssociationKey, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        ObjectiveC.Runtime.associate(object: object, to: self, for: key, policy: policy)
    }

    public func getAssociated<T: AnyObject>(for key: ObjectAssociationKey) -> T? {
        return ObjectiveC.Runtime.getAssociated(to: self, for: key)
    }

    public func removeAssociatedObjects() {
        ObjectiveC.Runtime.removeAssociatedObjects(from: self)
    }

    public func withAssociated<T: AnyObject, Result>(to object: AnyObject, for key: ObjectAssociationKey, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC, _ body: (_ object: inout T?) throws -> Result) rethrows -> Result {
        return try ObjectiveC.Runtime.withAssociated(to: self, for: key, policy: policy, body)
    }
}
