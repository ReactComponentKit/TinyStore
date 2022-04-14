//
//  AsyncEnumTypeTests.swift
//  Redux
//
//  Created by burt on 2022/04/07.
//

import XCTest
@testable import TinyStore

enum SomeError: Error {
    case systemError(code: Int)
    case unknownError
}

final class AsyncEnumTypeTests: XCTestCase {
    
    func testIdleStateEquality() {
        let a1: Async<Int> = .idle
        let a2: Async<Int> = .idle
        let a3: Async<String> = .idle
        let a4: Async<String> = .idle
        
        XCTAssertEqual(a1 == a2, true)
        XCTAssertEqual(a1 != a2, false)
        XCTAssertEqual(a3 == a4, true)
        XCTAssertEqual(a3 != a4, false)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testLoadingStateEquality() {
        let a1: Async<Int> = .loading
        let a2: Async<Int> = .loading
        let a3: Async<String> = .loading
        let a4: Async<String> = .loading
        
        XCTAssertEqual(a1 == a2, true)
        XCTAssertEqual(a1 != a2, false)
        XCTAssertEqual(a3 == a4, true)
        XCTAssertEqual(a3 != a4, false)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testValueStateEqualityWhenGivenSameValue() {
        let a1: Async<Int> = .value(value: 10)
        let a2: Async<Int> = .value(value: 10)
        let a3: Async<String> = .value(value: "Hello")
        let a4: Async<String> = .value(value: "Hello")
        
        XCTAssertEqual(a1 == a2, true)
        XCTAssertEqual(a1 != a2, false)
        XCTAssertEqual(a3 == a4, true)
        XCTAssertEqual(a3 != a4, false)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testValueStateEqualityWhenGivenDifferentValue() {
        let a1: Async<Int> = .value(value: 10)
        let a2: Async<Int> = .value(value: 99)
        let a3: Async<String> = .value(value: "Hello")
        let a4: Async<String> = .value(value: "World")
        
        XCTAssertEqual(a1 == a2, false)
        XCTAssertEqual(a1 != a2, true)
        XCTAssertEqual(a3 == a4, false)
        XCTAssertEqual(a3 != a4, true)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testErrorStateEqualityWhenGivenNilError() {
        let a1: Async<Int> = .error(value: nil)
        let a2: Async<Int> = .error(value: nil)
        let a3: Async<String> = .error(value: nil)
        let a4: Async<String> = .error(value: nil)
        
        XCTAssertEqual(a1 == a2, true)
        XCTAssertEqual(a1 != a2, false)
        XCTAssertEqual(a3 == a4, true)
        XCTAssertEqual(a3 != a4, false)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testErrorStateEqualityWhenGivenSameError() {
        let a1: Async<Int> = .error(value: SomeError.unknownError)
        let a2: Async<Int> = .error(value: SomeError.unknownError)
        let a3: Async<Int> = .error(value: SomeError.systemError(code: 100))
        let a4: Async<Int> = .error(value: SomeError.systemError(code: 100))
        
        XCTAssertEqual(a1 == a2, true)
        XCTAssertEqual(a1 != a2, false)
        XCTAssertEqual(a3 == a4, true)
        XCTAssertEqual(a3 != a4, false)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
    }
    
    func testErrorStateEqualityWhenGivenDifferentError() {
        let a1: Async<Int> = .error(value: SomeError.unknownError)
        let a2: Async<Int> = .error(value: SomeError.systemError(code: 400))
        let a3: Async<Int> = .error(value: SomeError.systemError(code: 404))
        let a4: Async<Int> = .error(value: SomeError.systemError(code: 500))
        let a5: Async<String> = .error(value: SomeError.unknownError)
        let a6: Async<String> = .error(value: SomeError.systemError(code: 500))
        
        XCTAssertEqual(a1 == a2, false)
        XCTAssertEqual(a1 != a2, true)
        XCTAssertEqual(a3 == a4, false)
        XCTAssertEqual(a3 != a4, true)
        XCTAssertEqual(a1 == a3, false)
        XCTAssertEqual(a1 != a3, true)
        XCTAssertEqual(a1 == a5, false)
        XCTAssertEqual(a1 != a5, true)
        XCTAssertEqual(a4 == a6, false)
        XCTAssertEqual(a4 != a6, true)
    }
    
    func testIncrementAsyncCount() async {
        enum States {
            case asyncCount
        }
        let countState = state(name: States.asyncCount, initialValue: Async<Int>.idle)
        
        let _ = effect(name: "CountEffect") { _ in
            let count: Tiny.State<Async<Int>> = useState(name: States.asyncCount)
            count.commit { $0 = .loading }
            await TinyStoreTests.wait(secs: 2)
            count.commit { $0 = .value(value: 10) }
            await TinyStoreTests.wait(secs: 2)
            count.commit { $0 = .error(value: SomeError.systemError(code: 1)) }
        }
        
        let _: Tiny.VoidEffect = useEffect(name: "CountEffect")
        XCTAssertEqual(countState.value, .idle)
        
        await TinyStoreTests.wait(secs: 2)
        XCTAssertEqual(countState.value, .loading)
        await TinyStoreTests.wait(secs: 2)
        XCTAssertEqual(countState.value, .value(value: 10))
        await TinyStoreTests.wait(secs: 2)
        XCTAssertEqual(countState.value, .error(value: SomeError.systemError(code: 1)))
    }
}
