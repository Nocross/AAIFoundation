/*
    Copyright (c) 2017 Andrey Ilskiy.

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


public class BundleResourceRequestOperation<T>: Operation, Resultful, ProgressReporting {

    let resourceRequest: NSBundleResourceRequest
    public private(set) var result: Outcome<T, Error> = nil
    private let aquisitionHandler: (Bundle) throws -> T

    public init(with request: NSBundleResourceRequest, accessHandler handler: @escaping ((Bundle) throws -> T)) {
        resourceRequest = request
        aquisitionHandler = handler

        super.init()
        execution.prepare(for: self)
    }

    @nonobjc
    public convenience init(with tags: Set<String>, accessHandler handler: @escaping ((Bundle) -> T)) {
        let request = NSBundleResourceRequest(tags: tags)
        self.init(with: request, accessHandler: handler)
    }

    public convenience init(with tags: Set<String>, bundle: Bundle, accessHandler handler: @escaping ((Bundle) -> T)) {
        let request = NSBundleResourceRequest(tags: tags, bundle: bundle)
        self.init(with: request, accessHandler: handler)
    }

    //MARK: - Overrides & Execution

    private let execution: Execution = AsynchronousExecution()

    public override var isExecuting: Bool {
        return execution.isExecuting
    }

    public override var isFinished: Bool {
        return execution.isFinished
    }

    public override var isCancelled: Bool {
        return execution.isCancelled || resourceRequest.progress.isCancelled
    }

    public override var isAsynchronous: Bool {
        return execution.isAsynchronous
    }

    public override func start() {

        let isCancelled = resourceRequest.progress.isCancelled
        if execution.start() && !isCancelled {
            execute()
        } else if isCancelled {
            execution.cancel()
        }
    }

    public override func cancel() {
        execution.cancel(finalized: false)

        let progress = resourceRequest.progress
        if !progress.isCancelled {
            progress.cancel()
        }
    }
    
    //MARK: - ProgressReporting
    
    public var progress: Progress {
        return resourceRequest.progress
    }

    //MARK: -

    private func execute() {
        resourceRequest.conditionallyBeginAccessingResources(completionHandler: conditinalAccessHandler)
    }

    private func conditinalAccessHandler(_ areResourcesAvailable: Bool) {
        if !isCancelled && areResourcesAvailable {
            accessHandler()
        } else {
            resourceRequest.beginAccessingResources(completionHandler: accessHandler)
        }
    }

    private func accessHandler(_ error: Error? = nil) {
        var outcome = Outcome<T, Error>.error(error)

        if error == nil {
            do {
                let result = try aquisitionHandler(resourceRequest.bundle)
                outcome = .conclusion(result)
            } catch {
                outcome = .error(error)
            }
        } else if let unwrapped = error as NSError?, unwrapped.code == NSUserCancelledError {
            execution.cancel(finalized: false)
        }
        
        result = outcome
        execution.finalize()
    }
}
