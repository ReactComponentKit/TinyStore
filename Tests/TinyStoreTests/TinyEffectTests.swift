//
//  TinyEffectTests.swift
//  TinyStoreTests
//
//  Created by sungcheol.kim on 2022/04/13.
//  https://github.com/ReactComponentKit/TinyStore
//

import XCTest
@testable import TinyStore

func returnName() async -> String {
    await wait(secs: 2)
    return "TinyStore"
}

final class TinyEffectTests: XCTestCase {
    func testInitEffect() async {
        effectValue(name: "fetchName", initialValue: "") { effect in
            let name = await returnName()
            return name
        }
        
        let fetchName: Tiny.EffectValue<String> = useEffectValue(name: "fetchName")
        await TinyStoreTests.wait(secs: 3)
        XCTAssertEqual(fetchName.value, "TinyStore")
    }
    
    func testComposeStates() async {
        enum States {
            case age
            case name
        }
        
        let ageState = state(name: States.age, initialValue: 20)
        effectValue(name: States.name, initialValue: "") { effect in
            let age: Int = effect.watch(state: States.age)
            let name = await returnName()
            return "\(name) - \(age)"
        }
        
        let nameEffect: Tiny.EffectValue<String> = useEffectValue(name: States.name)
        await TinyStoreTests.wait(secs: 3)
        XCTAssertEqual(nameEffect.value, "TinyStore - 20")
        
        ageState.value = 33
        await TinyStoreTests.wait(secs: 3)
        XCTAssertEqual(nameEffect.value, "TinyStore - 33")
    }
    
    func testChainingEffects() async {
        enum States {
            case inputA
            case inputB
            case output
        }
        
        enum Effects {
            case compute
            case result
        }
        
        let aState = state(name: States.inputA, initialValue: 0)
        let bState = state(name: States.inputB, initialValue: 0)
        state(name: States.output, initialValue: 0)
        
        effect(name: Effects.compute) { effect in
            let a: Int = effect.watch(state: States.inputA)
            let b: Int = effect.watch(state: States.inputB)
            let output: Tiny.State<Int> = useState(name: States.output)
            let result = a + b
            output.commit { $0 = result }
        }
        
        effectValue(name: Effects.result, initialValue: 0) { effect in
            let output: Int = effect.watch(state: States.output)
            print(output)
            return output
        }
        
        let _: Tiny.Effect = useEffect(name: Effects.compute)
        let outputEffect: Tiny.EffectValue<Int> = useEffectValue(name: Effects.result)
                
        aState.value = 10
        bState.value = 20
        
        
        await TinyStoreTests.wait(secs: 3)
        XCTAssertEqual(outputEffect.value, 30)
        
        aState.value = 100
        bState.value = 900
        await TinyStoreTests.wait(secs: 3)
        
        let resultEffect: Tiny.EffectValue<Int> = useEffectValue(name: Effects.result)
        XCTAssertEqual(resultEffect.value, 1000)
    }
}
