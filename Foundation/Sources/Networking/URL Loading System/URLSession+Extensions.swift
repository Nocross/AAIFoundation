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

extension URLSession {
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Result<(data: Data, response: URLResponse), Error>) -> Void) -> URLSessionDataTask {
        let handler = { (data: Data?, response: URLResponse?, error: Error?) in
            
            let isSuccess = data != nil && response != nil && error == nil
            let isFailure = data == nil && response == nil && error != nil
            
            let isSane = isSuccess || isFailure
            precondition(isSane)
            
            let result: Result<(data: Data, response: URLResponse), Error>
            result = isSuccess ? .success((data!, response!)) : .failure(error!)
            
            completionHandler(result)
        }
        
        return dataTask(with: request, completionHandler: handler)
    }
}

extension URLSessionTask {
    public var httpURLResponse: HTTPURLResponse? {
        guard let response = response else { return nil }
        
        return response as? HTTPURLResponse
    }
}
