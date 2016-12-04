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

public func class_derivedClassSwizzleImp(_ cls: AnyClass, selector: Selector, imp: IMP) -> Bool {
    var result = true

    if let method = class_getDerivedClassMethod(cls, selector: selector) {
        class_replaceMethod(cls, selector, imp, method_getTypeEncoding(method))
    } else if let method = class_getClassMethod(class_getSuperclass(cls), selector) {
        result = class_addMethod(cls, selector, imp, method_getTypeEncoding(method))
    } else {
        result = false
    }

    return result
}

public func class_getDerivedClassMethod(_ cls: AnyClass, selector: Selector) -> Method? {
    var count: UInt32 = 0;
    guard let methods = class_copyMethodList(cls, withUnsafeMutablePointer(to: &count, { return $0 })) , count > 0 else {
        return nil
    }

    var j: UInt32 = 0;
    let method = { methods.advanced(by: Int(j)).pointee };
    while(selector != method_getName(method()) && j < count) {
        j += 1;
    }

    let result: Method? = j < count ? method() : nil
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


public func object_dynamicCast<T: AnyObject, U: AnyObject>(obj: T, `class`: AnyClass) -> U? {
    var result: U? = nil
    if let objClass = object_getClass(obj) {
        if objClass == `class` {
            result = obj as? U
        }
    }

    return result
}


//---------

/*
public func class_swizzleImpsForSelector(targetClass: AnyClass, sourceClass: AnyClass, selector: Selector, backupSelector: Selector? = nil, isInstance: Bool = true) {

    let targetClassName = class_getName(targetClass)
    let sourceClassName = class_getName(sourceClass)

    if strcmp(targetClassName, sourceClassName) == 0 {
        if let method = isInstance ? class_getInstanceMethod(targetClass, selector) : class_getClassMethod(targetClass, selector), let imp = method_getImplementation(method) {

            class_replaceMethod(targetClass, backupSelector, imp, method_getTypeEncoding(method))
        }
    } else {
        
    }
}
*/

/*
 
 void class_swizzleImplsForSelector(Class const targetClass, Class const sourceClass, SEL const selector, SEL const backupSelector) {

 assert(targetClass && sourceClass && selector); /* mandatory parameters should be valid */

 const char * const targetClassName = class_getName(targetClass);
 const char * const sourceClassName = class_getName(targetClass);

 if (strcmp(targetClassName, sourceClassName) == 0) {
 const Method method = class_getClassMethod(targetClass, selector);
 assert(method); /* should exist */

 const IMP imp = method_getImplementation(method);
 assert(imp); /* should exist */

 class_replaceMethod(targetClass, backupSelector, imp, method_getTypeEncoding(method));
 } else {
 const size_t classesCount = 2;
 Method *swizzledMethods = calloc(classesCount, sizeof(Method));
 {
 const Class classes[2] = {targetClass, sourceClass};

 for (size_t i = 0; i < classesCount; i++) {
 swizzledMethods[i] = class_getSubclassClassMethod(classes[i], selector);
 }
 }
 const Method targetMethod = swizzledMethods[0];
 const Method sourceMethod = swizzledMethods[1];

 free(swizzledMethods);
 swizzledMethods = NULL;

 assert(targetMethod && sourceMethod); /* method should exist */

 const IMP sourceMethodIMP = method_getImplementation(sourceMethod);
 const char * const methodTypeEncoding = method_getTypeEncoding(sourceMethod);
 if (targetMethod) {
 const IMP targetMethodIMP = class_replaceMethod(targetClass, selector, sourceMethodIMP, methodTypeEncoding);
 if (backupSelector && targetMethodIMP) {
 class_addMethod(targetClass, backupSelector, targetMethodIMP, methodTypeEncoding);
 }
 }
 }
 }


 */

