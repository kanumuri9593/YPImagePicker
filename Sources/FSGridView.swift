//
//  FSGridView.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import Stevia

class FSGridView: UIView {
    
    let line1 = UIView()
    let line2 = UIView()
    let line3 = UIView()
    let line4 = UIView()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        isUserInteractionEnabled = false
        sv(
            line1,
            line2,
            line3,
            line4
        )
        
        let stroke: CGFloat = 0.5
        line1.top(0).width(stroke).bottom(0)
        addConstraint(item: line1, attribute: .right, toItem: self, attribute: .right, multiplier: 0.33, constant: 0)
        
        line2.top(0).width(stroke).bottom(0)
        addConstraint(item: line2, attribute: .right, toItem: self, attribute: .right, multiplier: 0.66, constant: 0)
        
        line3.left(0).height(stroke).right(0)
        addConstraint(item: line3, attribute: .bottom, toItem: self, attribute: .bottom, multiplier: 0.33, constant: 0)
        
        line4.left(0).height(stroke).right(0)
        addConstraint(item: line4, attribute: .bottom, toItem: self, attribute: .bottom, multiplier: 0.66, constant: 0)
        
        let color = UIColor.white.withAlphaComponent(0.6)
        line1.backgroundColor = color
        line2.backgroundColor = color
        line3.backgroundColor = color
        line4.backgroundColor = color
        
        applyShadow(to: line1)
        applyShadow(to: line2)
        
        applyShadow(to: line3)
        applyShadow(to: line4)
    }
    
    func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
