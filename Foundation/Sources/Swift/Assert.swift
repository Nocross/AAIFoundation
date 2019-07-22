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

//MARK: -

public func precondition<U>(subject: Any, to: U.Type, message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
    let asOfType = (subject as? U.Type) != nil
    let isOfType = subject is U.Type
    
    precondition(isOfType && asOfType, "Should conform to type - \(String(describing: U.self))")
}

public func preconditionFailure<U>(subject: Any, to: U.Type, message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    
    preconditionFailure("Subject - \(String(describing: subject)) - Should conform to type - \(String(describing: U.self))")
}


//MARK: -

public func fatalNotImplementedError(message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    
    let message = message()
    
    var text = "Not Implemented"
    
    if !message.isEmpty {
        text.append("\n\(message)")
    }
    
    fatalError(text, file: file, line: line)
}


public func fatalUnknownValueError(_ value: Any, message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    
    let type = String(describing: Swift.type(of: value))
    let value = String(describing: value)
    
    let message = """
    Uknown \(type) value - \(value)
    \(message())
    """
    
    fatalError(message, file: file, line: line)
}
