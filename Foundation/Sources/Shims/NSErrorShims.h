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

#ifndef NSErrorShims_h
#define NSErrorShims_h

@import Foundation.NSObjCRuntime;
@import ObjectiveC.message;

NS_ASSUME_NONNULL_BEGIN

/**
 Declaration(s) for NSError overlay
 https://github.com/apple/swift/blob/master/stdlib/public/SwiftShims/NSErrorShims.h
 */
NS_INLINE void __errorPerformRecoverySelector(_Nullable id delegate, SEL selector, BOOL success, void *_Nullable contextInfo) {
    
    void (*msg)(_Nullable id, SEL, BOOL, void* _Nullable) =
    (void(*)(_Nullable id, SEL, BOOL, void* _Nullable))objc_msgSend;
    msg(delegate, selector, success, contextInfo);
}

NS_ASSUME_NONNULL_END

#endif /* NSErrorShims_h */
