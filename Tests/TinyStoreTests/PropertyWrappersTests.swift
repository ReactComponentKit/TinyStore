//
//  PropertyWrappersTests.swift
//  TinyStore
//
//  Created by burt on 2022/04/16.
//

import XCTest
@testable import TinyStore

struct TestStore {
    static let name = "TestStore"
    
    enum State {
        case name
        case age
        case nameAndAge
    }
    
    enum Effect {
        case logging
    }
    
    init() {
        let testStore = store(name: TestStore.name)
        state(name: State.name, initialValue: "A", store: testStore)
        state(name: State.age, initialValue: 20, store: testStore)
        effectValue(name: State.nameAndAge, initialValue: "", store: testStore) { effect in
            let store = useStore(name: TestStore.name)
            let name: Tiny.State<String> = effect.watch(state: TestStore.State.name, store: store)
            let age: Tiny.State<Int> = effect.watch(state: TestStore.State.age, store: store)
            return "\(name.value)-\(age.value)"
        }
        effect(name: Effect.logging, store: testStore) { effect in
            let store = useStore(name: TestStore.name)
            let nameAndAge: Tiny.EffectValue<String> = effect.watch(effectValue: TestStore.State.nameAndAge, store: store)
            print(nameAndAge.value)
        }
    }
}

final class PropertyWrappersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let _ = TestStore()
    }
    
    func testUseStore() {
        @UseStore(name: TestStore.name)
        var store: Tiny.ScopeStore
        
        XCTAssertNotNil(store.states[TestStore.State.name])
        XCTAssertNotNil(store.states[TestStore.State.age])
        XCTAssertNotNil(store.effectValues[TestStore.State.nameAndAge])
    }
    
    func testUseState() {
        @UseState(name: TestStore.State.name)
        var name: Tiny.State<String>
        
        @UseState(name: TestStore.State.age)
        var age: Tiny.State<Int>
        
        XCTAssertEqual(name.value, "A")
        XCTAssertEqual(age.value, 20)
    }
    
    func testUseEffectValue() async {
        @UseEffectValue(name: TestStore.State.nameAndAge)
        var nameAndAge: Tiny.EffectValue<String>
        XCTAssertEqual(nameAndAge.value, "")
        await contextSwitching()
        XCTAssertEqual(nameAndAge.value, "A-20")
    }
    
    func testUseEffectValue2() async {
        @UseState(name: TestStore.State.name)
        var name: Tiny.State<String>
        
        @UseState(name: TestStore.State.age)
        var age: Tiny.State<Int>
        
        @UseEffectValue(name: TestStore.State.nameAndAge)
        var nameAndAge: Tiny.EffectValue<String>
        XCTAssertEqual(nameAndAge.value, "")
        
        @UseEffect(name: TestStore.Effect.logging)
        var logging: Tiny.Effect
        XCTAssertNotNil(logging)

        await TinyStoreTests.wait(secs: 1)
        XCTAssertEqual(nameAndAge.value, "A-20")
        
        name.value = "B"
        age.value = 30
        await TinyStoreTests.wait(secs: 1)
        XCTAssertEqual(nameAndAge.value, "B-30")
    }
}
