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


import ObjectiveC

public func class_derivedClassSwizzleImp(_ cls: AnyClass, selector: Selector, imp: IMP) -> (success: Bool, previous: IMP?) {
    var success = true
    var previous: IMP? = nil

    if let method = class_getDerivedClassMethod(cls, selector: selector) {
        previous = class_replaceMethod(cls, selector, imp, method_getTypeEncoding(method))
    } else if let method = class_getClassMethod(class_getSuperclass(cls), selector) {
        success = class_addMethod(cls, selector, imp, method_getTypeEncoding(method))
    } else {
        success = false
    }

    return (success, previous)
}

public func class_getDerivedClassMethod(_ cls: AnyClass, selector: Selector) -> Method? {
    var count: UInt32 = 0;
    guard let methods = class_copyMethodList(cls, withUnsafeMutablePointer(to: &count, { return $0 })) , count > 0 else {
        return nil
    }

    var j: UInt32 = 0;
    var method: Method!
    var name: Selector!
    repeat {
        method = methods.advanced(by: numericCast(j)).pointee
        name = method_getName(method)

        j += 1;
    } while (!sel_isEqual(selector, name) && j < count)

    let result: Method? = j < count ? method : nil
    free(methods)

    return result
}

public func class_getDerivedClassImp(_ cls: AnyClass, selector: Selector) -> IMP? {
    var result: IMP? = nil

    if let method = class_getDerivedClassMethod(cls, selector: selector) {
        result = method_getImplementation(method)
    }

    return result
}


public func object_dynamicCast<T: AnyObject, U: AnyObject>(obj: T, `class`: U.Type) -> U? {
    var result: U? = nil
    if let objClass = object_getClass(obj) {
        if objClass === `class` {
            result = unsafeDowncast(obj, to: `class`)
        }
    }

    return result
}
