//
//  ScopeStoreTests.swift
//  TinyStoreTests
//
//  Created by burt on 2022/04/15.
//

import XCTest
@testable import TinyStore

final class ScopeStoreTests: XCTestCase {
    func testScopeStore() {
        enum MyStore {
            case local
        }
        store(name: MyStore.local)
        XCTAssertNotNil(useStore(name: MyStore.local))
    }
    
    func testScopeStoreHasState() {
        enum MyStore {
            case local
        }
        let store = store(name: MyStore.local)
        
        enum MyState {
            case name
        }
        state(name: MyState.name, initialValue: "TinyStore", store: store)
        
        XCTAssertNil(Tiny.globalStore.states[MyState.name])
        XCTAssertNotNil(store.states[MyState.name])
        
        let nameState: Tiny.State<String> = useState(name: MyState.name)
        XCTAssertNotNil(nameState)
        XCTAssertEqual(nameState.value, "TinyStore")
    }
}
