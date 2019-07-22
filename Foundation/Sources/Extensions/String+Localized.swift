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

extension String {
    public struct Localized {
        private init() {}
    }
}

extension String.Localized {
    public struct Common {
        private init() {}

        public struct Dismissal {
            private init() {}
        }

        public struct Confirmation {
            private init() {}
        }
    }
    
    public struct Error {
        private init() {}
        
        public struct Recovery {
            private init() {}
            
            public struct Option {
                private init() {}
            }
        }
        
        public struct Unknown {
            private init() {}
        }
    }
}

extension String.Localized.Error.Unknown {
    public static var description: String {
        let value = "Unknown error"
        var result = NSLocalizedString("error.recovery.unknown.desctiption", value: value, comment: "'Unknown' error description")
        
        if result == value {
            let bundle = Bundle(for: Foundation.self)
            
            result = NSLocalizedString("error.recovery.unknown.desctiption", bundle: bundle, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
    
    public static var failureReason: String {
        let value = "Failure reason - Unknown"
        var result = NSLocalizedString("error.recovery.unknown.failure-reason", value: value, comment: "'Unknown' error failure reason")
        
        if result == value {
            let bundle = Bundle(for: Foundation.self)
            
            result = NSLocalizedString("error.recovery.unknown.failure-reason", bundle: bundle, value: value, comment: "'Unknown' error failure reason")
        }
        
        return result
    }
    
    public static var recoverySuggestion: String {
        let value = "Try again or come back later"
        var result = NSLocalizedString("error.recovery.unknown.recovery-suggestion", value: value, comment: "'Unknown' error description")
        
        if result == value {
            let bundle = Bundle(for: Foundation.self)
            
            result = NSLocalizedString("error.recovery.unknown.recovery-suggestion", bundle: bundle, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
    
    public static var helpAnchor: String {
        let value = "No 'Help' documentation available"
        var result = NSLocalizedString("error.recovery.unknown.help-anchor", value: value, comment: "'Unknown' error description")
        
        if result == value {
            let bundle = Bundle(for: Foundation.self)
            
            result = NSLocalizedString("error.recovery.unknown.help-anchor", bundle: bundle, value: value, comment: "'Unknown' error description")
        }
        
        return result
    }
}

extension String.Localized.Error.Recovery.Option {
    public static var retry: String {
        return NSLocalizedString("error.recovery.option.retry", value: "Retry", comment: "'Retry' error recovery option")
    }
    
    public static var report: String {
        return NSLocalizedString("error.recovery.option.report", value: "Report", comment: "'Report' error recovery option")
    }
}
