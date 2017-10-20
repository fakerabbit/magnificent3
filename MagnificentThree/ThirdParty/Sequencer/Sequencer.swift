//
//  Sequencer.swift
//  Sequencer
//
//  Created by Tal Bereznitskey on 6/4/14.
//  Copyright (c) 2014 ketacode. All rights reserved.
//

import Foundation

class Sequencer {

    typealias SequencerNext = ((AnyObject?) -> Void)
    typealias SequencerStep = (AnyObject?, SequencerNext) -> Void
    
    var steps: [SequencerStep]  = []
    
    func run() {
        runNextStepWithResult(nil)
    }
    
    func enqueueStep(_ step: @escaping SequencerStep) {
        steps.append(step)
    }
    
    func dequeueNextStep() -> (SequencerStep) {
        return steps.remove(at: 0)
    }
    
    func runNextStepWithResult(_ result: AnyObject?) {
        if (steps.count <= 0) {
            return
        }
        
        let step = dequeueNextStep()
        step(result, { self.runNextStepWithResult($0) })
    }
    
}
