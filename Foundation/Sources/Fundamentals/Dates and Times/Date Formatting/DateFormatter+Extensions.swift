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

extension DateFormatter {
    public convenience init(dateStyle: DateFormatter.Style = .long, timeStyle: DateFormatter.Style = .long) {
        self.init()
        
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
    
    public static var shortStyleFormatter: DateFormatter {
        return DateFormatter(dateStyle: .short, timeStyle: .short)
    }
    
    public static var mediumStyleFormatter: DateFormatter {
        return DateFormatter(dateStyle: .medium, timeStyle: .medium)
    }
    
    public static var longStyleFormatter: DateFormatter {
        return DateFormatter(dateStyle: .long, timeStyle: .long)
    }
    
    public static var fullStyleFormatter: DateFormatter {
        return DateFormatter(dateStyle: .full, timeStyle: .full)
    }
}
