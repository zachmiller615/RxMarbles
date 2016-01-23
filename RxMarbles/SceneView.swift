//
//  SceneView.swift
//  RxMarbles
//
//  Created by Roman Tutubalin on 21.01.16.
//  Copyright © 2016 Roman Tutubalin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SceneView: UIView {
    var animator: UIDynamicAnimator?
    var sourceTimeline: SourceTimelineView! {
        didSet {
            sourceTimeline.center.y = center.y * 0.33
            addSubview(sourceTimeline)
            
            if rxOperator.code.first != nil {
                sourceTimeline.labelsText = rxOperator.code.first
            }
            
            let initial = rxOperator.initial
            for t in initial.line1 {
               sourceTimeline.addEventToTimeline(t, animator: animator, isEditing: editing)
            }
        }
    }
    var secondSourceTimeline: SourceTimelineView! {
        didSet {
            secondSourceTimeline.center.y = center.y * 0.66
            addSubview(secondSourceTimeline)
            
            if rxOperator.code.last != nil {
                secondSourceTimeline.labelsText = rxOperator.code.last
            }
            
           
            let initial = rxOperator.initial
            for t in initial.line2 {
               secondSourceTimeline.addEventToTimeline(t, animator: animator, isEditing: editing)
            }
        }
    }
    var resultTimeline: ResultTimelineView! {
        didSet {
            resultTimeline.center.y = center.y
            addSubview(resultTimeline)
        }
    }
    var trashView = UIImageView(image: Image.trash)
    var rxOperator: Operator
    var editing: Bool!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(rxOperator: Operator) {
        self.rxOperator = rxOperator
        super.init(frame: CGRectZero)
        trashView.frame = CGRectMake(0, 0, 60, 60)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        resultTimeline.frame = CGRectMake(0, 0, bounds.size.width, 40)
        resultTimeline.center.y = 300
        
        sourceTimeline.frame = CGRectMake(0, 0, bounds.size.width, 80)
        sourceTimeline.center.y = 140
        refreshSourceEventsCenters(sourceTimeline)
        
        if secondSourceTimeline != nil {
            secondSourceTimeline.frame = CGRectMake(0, 0, bounds.size.width, 80)
            secondSourceTimeline.center.y = 220
            refreshSourceEventsCenters(secondSourceTimeline)
        }
        
        trashView.center.x = bounds.size.width / 2.0
        trashView.center.y = bounds.size.height - 50
        
        updateResultTimeline()
    }
    
    private func refreshSourceEventsCenters(timeline: SourceTimelineView) {
        timeline.sourceEvents.forEach {
            $0.center.x = timeline.xPositionByTime($0.recorded.time)
            $0.center.y = timeline.bounds.height / 2.0
            if let snap = $0.snap {
                snap.snapPoint.x = CGFloat($0.recorded.time) >= 0 ? timeline.xPositionByTime($0.recorded.time) : 0.0
                snap.snapPoint.y = timeline.center.y
            }
        }
    }
    
    func updateResultTimeline() {
        if let secondSourceTimeline = secondSourceTimeline {
            resultTimeline.updateEvents((sourceTimeline.sourceEvents, secondSourceTimeline.sourceEvents))
        } else {
            resultTimeline.updateEvents((sourceTimeline.sourceEvents, nil))
        }
    }
    
    func showTrashView() {
        addSubview(trashView)
        trashView.hidden = false
        trashView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        trashView.alpha = 0.05
        UIView.animateWithDuration(0.3) { _ in
            self.trashView.alpha = 0.2
            self.trashView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            self.trashView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    func hideTrashView() {
        trashView.hideWithCompletion({ _ in self.trashView.removeFromSuperview() })
    }
    
    private func randomNumber() -> Int {
        return Int(arc4random_uniform(10) + 1)
    }
    
}