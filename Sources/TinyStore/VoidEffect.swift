//
//  VoidEffect.swift
//  TinyStore
//
//  Created by burt on 2022/04/13.
//

import Foundation
import Combine

extension Tiny {
    public class VoidEffect: ObservableObject {
        private var watchStates: [AnyHashable: Bool] = [:]
        internal var cancellable = Set<AnyCancellable>()
        internal let name: AnyHashable
        internal let job: (VoidEffect) async -> Void
        internal init(name: AnyHashable, job: @escaping (VoidEffect) async -> Void) {
            self.name = name
            self.job = job
            self.run()
        }
        
        public func watch<Value: Equatable>(state name: AnyHashable) -> Tiny.State<Value> {
            let state = globalStore.states[name] as! Tiny.State<Value>
            guard watchStates[state.name] == nil else { return state }
            watchStates[state.name] = true
            state.$value
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.run()
                }
                .store(in: &cancellable)
            return state
        }
        
        internal func run() {
            Task.detached(priority: .userInitiated) {
                await self.job(self)
            }
        }
    }
}
