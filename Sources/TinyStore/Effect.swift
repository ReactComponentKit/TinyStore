//
//  Effect.swift
//  TinyStore
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import Foundation
import Combine

/// Tiny.Effect<Value>
/// represent side-effect which could return value.
extension Tiny {
    public class Effect<Value: Equatable>: ObservableObject {
        @Published
        private var innerValue: Value
        @Published
        public private(set) var value: Value
        private var watchStates: [AnyHashable: Bool] = [:]
        internal var cancellables = Set<AnyCancellable>()
        internal let name: AnyHashable
        internal let job: (Effect) async -> Value
        private var cacheDidInitialRun = false
        internal var didInitialRun = false {
            didSet {
                guard didInitialRun == true else { return }
                guard cacheDidInitialRun == false else { return }
                cacheDidInitialRun = true
                run()
            }
        }
        
        internal init(name: AnyHashable, initialValue: Value, job: @escaping (Effect) async -> Value) {
            self.name = name
            self.innerValue = initialValue
            self.value = initialValue
            self.job = job
            
            if #available(iOS 14, macOS 11, *) {
                self.$innerValue
                    .removeDuplicates()
                    .assign(to: &self.$value)
            } else {
                self.$innerValue
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] value in
                        self?.value = value
                    })
                    .store(in: &cancellables)
            }
        }
        
        public func watch<Value: Equatable>(state name: AnyHashable) -> State<Value> {
            let state = globalStore.states[name] as! State<Value>
            guard watchStates[state.name] == nil else { return state }
            watchStates[state.name] = true
            state.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellables)
            return state
        }
        
        @MainActor
        internal func commitOnMainThread(new: Value, old: Value) {
            if new != old {
                self.innerValue = new
            }
        }
        
        public func run() {
            Task.detached(priority: .userInitiated) {
                let old = self.value
                let new = await self.job(self)
                await self.commitOnMainThread(new: new, old: old)
            }
        }
    }
}
