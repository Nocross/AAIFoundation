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

import Foundation

public protocol ExpressionPredicateVariableNameProtocol: StringRepresentableIdentifierProtocol {}

public protocol ExpressionPredicateVariableValueProtocol {}

public protocol ExpressionPredicateSubstitutionVariableProcol {
    associatedtype Name: ExpressionPredicateVariableNameProtocol
    associatedtype Value: ExpressionPredicateVariableValueProtocol
    
    var name: Name { get }
    var value: Value { get }
}

extension NSPredicate {
    public struct Substitution {
        private init() {}
    }
}

extension NSPredicate.Substitution {
    public typealias ValueType = ExpressionPredicateVariableValueProtocol
    
    public struct Variable<ValueType>: ExpressionPredicateSubstitutionVariableProcol where ValueType : NSPredicate.Substitution.ValueType {
        public typealias Value = ValueType
        
        public init(name: Name, value: Value) {
            self.name = name
            self.value = value
        }
        
        public let name: Name
        public let value: Value
    }
}

extension NSPredicate.Substitution {
    public struct Name: ExpressionPredicateVariableNameProtocol {
        
        //MARK: - RawRepresentable
        
        public typealias RawValue = String
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
}

extension NSNull: ExpressionPredicateVariableValueProtocol {}

extension NSNumber: ExpressionPredicateVariableValueProtocol {}

extension String: ExpressionPredicateVariableValueProtocol {}

extension Int: ExpressionPredicateVariableValueProtocol {}

extension Bool: ExpressionPredicateVariableValueProtocol {}
