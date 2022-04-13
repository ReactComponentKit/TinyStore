//
//  State.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation

/// Tiny.State<Value>
/// represent state value
extension Tiny {
    public class State<Value: Equatable>: ObservableObject {
        @Published
        /// not prevent direct set value
        /// but must set value on main thread
        // private(set) var value: Value
        public var value: Value
        
        internal let name: AnyHashable
        
        internal init(name: AnyHashable, initialValue: Value) {
            self.name = name
            self.value = initialValue
        }
        
        @MainActor
        private func commitOnMainThread(new: Value, old: Value) {
            if new != old {
                self.value = new
            }
        }
        
        /// set state value on the other thread.
        /// Do Not Use in the effect that watches this state.
        public func commit(_ mutation: (inout Value) -> Void) {
            let old = self.value
            var mutable = self.value
            mutation(&mutable)
            Task { [mutable, old] in
                await self.commitOnMainThread(new: mutable, old: old)
            }
        }
    }
}

extension Tiny.State: CustomStringConvertible {
    public var description: String {
        return "\(self.value)"
    }
}

extension Tiny.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(self.value)"
    }
}

extension Tiny.State: Equatable {
    public static func == (lhs: Tiny.State<Value>, rhs: Tiny.State<Value>) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
    
    public static func == <Other>(lhs: Tiny.State<Value>, rhs: Tiny.State<Other>) -> Bool {
        return false
    }
    
    public static func != <Other>(lhs: Tiny.State<Value>, rhs: Tiny.State<Other>) -> Bool {
        return true
    }
}
