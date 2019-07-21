/*
    Copyright (c) 2019 Andrey Ilskiy.

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

#import "NSError+ExceptionPromotion.h"
#import <AAIFoundation/AAIFoundation-Swift.h>

@import ObjectiveC.runtime;

NSErrorDomain const ExceptionErrorDomain = @"ExceptionErrorDomain";

NSErrorUserInfoKey const PromotedExceptionKey = @"PromotedExceptionKey";

OBJC_EXPORT BOOL object_isKindOfClass(id _Nullable obj, Class _Nullable cls);
OBJC_EXPORT BOOL object_isMemeberOfClass(id _Nullable obj, Class _Nullable cls);
OBJC_EXPORT BOOL object_conformsToProtocol(id _Nullable obj, Protocol * _Nullable protocol);

@implementation NSError (Exception)

+ (instancetype)errorWithDomain:(NSException *)exception userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict {
    return [[self alloc] initWithException:exception userInfo:dict];
}

- (instancetype)initWithException:(NSException *)exception userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
    NSMutableDictionary<NSErrorUserInfoKey, id> * const userInfo = dict == nil ? [NSMutableDictionary dictionary] : [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:NO];
    userInfo[PromotedExceptionKey] = exception;
    
    return [self initWithDomain:ExceptionErrorDomain code:PromotedExceptionError userInfo: userInfo];
}

- (NSException *)promotedException {
    id result = self.userInfo[PromotedExceptionKey];
    NSParameterAssert(object_isKindOfClass(result, [NSException class]));
    
    return result;
}

@end

#pragma mark -

BOOL object_conformsToProtocol(id obj, Protocol *protocol) {
    BOOL result = NO;
    
    BOOL const isSane = obj != nil && protocol != NULL;
    if(isSane) {
        Class const cls = object_getClass(obj);
        
        result = class_conformsToProtocol(cls, protocol);
    }
    
    return result;
}

BOOL object_isKindOfClass(id obj, Class cls) {
    BOOL result = NO;
    
    BOOL const isSane = obj != nil && cls != Nil && object_isClass(obj) == NO;
    if(isSane) {
        Class const objCls = object_getClass(obj);
        
        Class superCls = objCls;
        do {
            result = superCls == cls;
            
            superCls = class_getSuperclass(superCls);
        } while (!result && superCls != Nil);
    }
    
    return result;
}

BOOL object_isMemeberOfClass(id obj, Class cls) {
    BOOL result = NO;
    
    BOOL const isSane = obj != nil && cls != Nil;
    if(isSane) {
        Class const objCls = object_getClass(obj);
        
        result = objCls == cls;
    }
    
    return result;
}
