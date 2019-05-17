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

public struct MapTableCollection<KeyType, ObjectType>: Collection where KeyType : AnyObject, ObjectType : AnyObject {
    public typealias Element = (key: KeyType, object: ObjectType)
    
    private let mapTable: NSMapTable<KeyType, ObjectType>
    
    public init(_ mapTable: NSMapTable<KeyType, ObjectType>) {
        self.mapTable = mapTable
    }
    
    //MARK: - Sequence
    
    public __consuming func makeIterator() -> Iterator {
        
        let key = mapTable.keyEnumerator()
        let object = mapTable.objectEnumerator() ?? NSEnumerator()
        
        return Iterator(enumerator: (key, object))
    }
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = MapTableCollection.Element
        
        private var iterator: (key: NSFastEnumerationIterator, object: NSFastEnumerationIterator)
        
        fileprivate init() {
            let empty = NSFastEnumerationIterator(NSEnumerator())
            iterator = (empty, empty)
        }
        
        fileprivate init(enumerator: (key: NSEnumerator, object: NSEnumerator)) {
            let key = enumerator.key.makeIterator()
            let object = enumerator.object.makeIterator()
            iterator = (key, object)
        }
        
        public mutating func next() -> Element? {
            let key = iterator.key.next() as? KeyType
            let object = iterator.object.next() as? ObjectType
            
            let isSane = !((key != nil && object == nil) || (key == nil && object != nil))
            precondition(isSane)
            
            let hasEnded = key == nil && object == nil
            
            return hasEnded ? nil : (key!, object!)
        }
        
        fileprivate static var empty: Iterator {
            return Iterator()
        }
    }
    
    //MARK: - Collection
    
    public var startIndex: Index {
        let count = mapTable.count
        
        return Index(offset: 0, count: count, iterator: makeIterator())
    }
    
    public var endIndex: Index {
        let value = mapTable.count
        let iterator = Iterator.empty
        return Index(offset: value, count: value, iterator: iterator)
    }
    
    public subscript(position: Index) -> Element {
        precondition(position != endIndex, "\"past-the-end\" is not a valid position")
        
        return position.element
    }
    
    public func index(after i: Index) -> Index {
        var result: Index
        
        if i.offset >= mapTable.count {
            result = endIndex
        } else {
            var iterator = makeIterator()
            var element: Element?
            for _ in 0 ..< i.offset {
                element = iterator.next()
                precondition(element != nil, "Unexpected end of collection")
            }
            
            result = Index(offset: i.offset, count: i.count, iterator: iterator)
            result.advance()
        }
        
        return result
    }
    
    public struct Index: Comparable, Hashable {
        fileprivate private(set) var offset: Int
        fileprivate let count: Int
        
        fileprivate private(set) var element: Iterator.Element
        private var iterator: Iterator
        
        fileprivate init(offset: Int, count: Int, iterator: Iterator) {
            self.offset = offset
            self.count = count
            self.iterator = iterator
            
            let element = self.iterator.next()
            self.element = element!
        }
        
        fileprivate mutating func advance() {
            if offset + 1 < count, let element = iterator.next() {
                self.offset += 1
                self.element = element
            } else {
                assert(offset == count)
            }
        }
        
        //MARK: - Comparable
        
        public static func < (lhs: Index, rhs: Index) -> Bool {
            return lhs.offset < rhs.offset
        }
        
        //MARK: - Hashable
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(offset)
            hasher.combine(count)
        }
        
        //MARK: - Equatable
        
        public static func == (lhs: Index, rhs: Index) -> Bool {
            return lhs.offset == rhs.offset && lhs.count == rhs.count
        }
    }
}

//MARK: -

fileprivate class MapTableSequenceReference<KeyType, ObjectType>: NSObject, Sequence where KeyType : AnyObject, ObjectType : AnyObject {
    
    let wraped: MapTableCollection<KeyType, ObjectType>
    
    public init(_ instance: MapTableCollection<KeyType, ObjectType>) {
        wraped = instance
    }
    
    public convenience init(_ mapTable: NSMapTable<KeyType, ObjectType>) {
        let instance = MapTableCollection(mapTable)
        self.init(instance)
    }
    
    //MARK: - Sequence
    
    public typealias Iterator = MapTableCollection<KeyType, ObjectType>.Iterator
    
    @nonobjc
    public __consuming func makeIterator() -> MapTableSequenceReference<KeyType, ObjectType>.Iterator {
        return wraped.makeIterator()
    }
}

//MARK: -

/*
 //TODO: File a bug - Crashes compiler
 
@inlinable
public func sequence<KeyType, ObjectType>(_ mapTable: NSMapTable<KeyType, ObjectType>) -> UnfoldSequence<(KeyType, ObjectType), (NSMapTable<KeyType, ObjectType>, NSFastEnumerationIterator, NSFastEnumerationIterator)> where KeyType : AnyObject, ObjectType : AnyObject {
    
    let key = mapTable.keyEnumerator()
    let object = mapTable.objectEnumerator() ?? NSEnumerator()
    
    let state = (mapTable, key.makeIterator(), object.makeIterator())
    let result = sequence(state: state) { (state) -> (KeyType, ObjectType)? in
        let key = state.1.next() as? KeyType
        let object = state.2.next() as? ObjectType
        
        let isSane = !((key != nil && object == nil) || (key == nil && object != nil))
        precondition(isSane)
        
        let hasEnded = key == nil && object == nil
        
        return hasEnded ? nil : (key!, object!)
    }

    return result
}
*/
