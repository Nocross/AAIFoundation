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

public protocol Resultful {
    associatedtype Resultant
    associatedtype ErrorType: Swift.Error
    
    var result: Outcome<Resultant, ErrorType> { get }
}

//MARK: -

public enum Outcome<Resultant, Error>: ExpressibleByNilLiteral where Error : Swift.Error {
    case error(Error?)
    case conclusion(Resultant)
    
    private enum Fallback: String, Swift.Error {
        case undefined = "Undefined"
    }

    public init(nilLiteral: ()) {
        self = .error(nil)
    }
    
    public func get() throws -> Resultant {
        let result: Resultant
        
        switch self {
        case .conclusion(let some):
            result = some
        case .error(let error):
            throw error ?? Fallback.undefined
        }
        
        return result
    }
    
    public func map<NewResultant>(_ transform: (Resultant) throws -> NewResultant) rethrows -> Outcome<NewResultant, Error> {
        
        let result: Outcome<NewResultant, Error>
        
        switch self {
        case .conclusion(let other):
            let some = try transform(other)
            
            result = .conclusion(some)
        case .error(let some):
            result = .error(some)
        }
        
        return result
    }
    
    public init(catching body: () throws -> Resultant) {
        do {
            let result = try body()
            
            self = .conclusion(result)
        } catch {
            guard let some = error as? Error else { preconditionFailure() }
            self = .error(some)
        }
    }
}

//MARK: -

extension Outcome : Equatable where Resultant : Equatable, Error : Equatable {}

extension Outcome : Hashable where Resultant : Hashable, Error : Hashable {}

//MARK: -

#if swift(>=5.0)

extension Outcome {
    public func toResult() -> Result<Resultant, Error?> {
        switch self {
        case .conclusion(let some):
            return .success(some)
            
        case .error(let wraped):
            return .failure(wraped)
        }
    }
}

//MARK: -

extension Swift.Result {
    public func toOutcome() -> Outcome<Success, Failure> {
        switch self {
        case .success(let some):
            return .conclusion(some)
            
        case .failure(let error):
            return .error(error)
        }
    }
}

extension Swift.Result : ExpressibleByNilLiteral where Failure : ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .failure(nil)
    }
}

extension Swift.Optional : Error where Wrapped : Error {}

#else

extension Outcome {
    public static func == (lhs: Outcome<Resultant, Error>, rhs: Outcome<Resultant, Error>) -> Bool {
        var result = false
        
        switch lhs {
        case .conclusion(let lhr):
            switch rhs {
            case .conclusion(let rhr):
                result = lhr == rhr
            case .error(_):
                break
            }
            
        case .error(let lhr):
            switch rhs {
            case .conclusion(_):
                break
            case .error(let rhr):
                result = lhr == rhr
            }
        }
        
        return result
    }
}

#endif /* swift(>=5.0) */
