//
//  FSPager.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit
import Stevia

final class PagerMenu: UIView {
    
    var didSetConstraints = false
    var menuItems = [MenuItem]()
    var selector = UIView()
    var separator = UIView()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        backgroundColor = .white
        
        
        sv(
            separator,
            selector
        )
        
        layout(
            |separator| ~ 0.5,
            0
        )
        
        layout(
            |selector.width(300) ~ 1,
            0.5
        )
        
//        selector.backgroundColor = .black
        separator.backgroundColor = UIColor(r: 167, g: 167, b: 167)
    }
    
    var separators = [UIView]()
    
    func setUpMenuItemsConstraints() {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(menuItems.count)
        var previousMenuItem: MenuItem?
        for (_, m) in menuItems.enumerated() {
            addSubview(m)
            m.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(item: m, attribute: .top, toItem: self)
            addConstraint(item: m, attribute: .height, toItem: self)
            addConstraint(item: m, attribute: .width, constant: menuItemWidth)
            if let pm = previousMenuItem {
                addConstraint(item: m, attribute: .left, toItem: pm, attribute:.right)
            } else {
                addConstraint(item: m, attribute: .left, toItem: self)
            }
            
            if let previousMenuItem = previousMenuItem {
                //Add separator next to it
                let separator = UIView()
                addSubview(separator)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = .clear
                addConstraint(item: separator, attribute: .width, constant:1)
                addConstraint(item: separator, attribute: .left, toItem: previousMenuItem,
                              attribute: .right)
                addConstraint(item: separator, attribute: .top, toItem: self, constant: 7)
                addConstraint(item: separator, attribute: .bottom, toItem: self, constant: -7)
            }
            
            previousMenuItem = m
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }
    
    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
}

final class MenuItem: UIView {
    
    var text = UILabel()
    var button = UIButton()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        backgroundColor = .clear
        
        sv(
            text,
            button
        )
        
        text.centerInContainer()
        button.fillContainer()
        
        text.style { l in
            l.textAlignment = .center
            l.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            l.textColor = self.unselectedColor()
        }
    }
    
    func selectedColor() -> UIColor {
        return UIColor(r: 38, g: 38, b: 38)
    }
    
    func unselectedColor() -> UIColor {
        return UIColor(r: 153, g: 153, b: 153)
    }
    
    func select() {
        text.textColor = selectedColor()
    }
    
    func unselect() {
        text.textColor = unselectedColor()
    }
}

final class PagerView: UIView {
    
    var header = PagerMenu()
    var scrollView = UIScrollView()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 237/255, alpha: 1)
        
        sv(
            scrollView,
            header
        )
        
        (|header| ~ 50).bottom(0)
        scrollView.fillContainer()
        
        clipsToBounds = false
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
    }
    
    func animateSelectorToPage(_ page: Int) {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width
            / CGFloat(header.menuItems.count)
        header.selector.leftConstraint?.constant = CGFloat(page) * menuItemWidth
        UIView.animate(withDuration: 0.2, animations:layoutIfNeeded)
    }
}

protocol PagerDelegate: class {
    func pagerScrollViewDidScroll(_ scrollView: UIScrollView)
    func pagerDidSelectController(_ vc: UIViewController)
}

final class Pager: UIViewController, UIScrollViewDelegate {
    
    weak var delegate: PagerDelegate?
    var controllers = [UIViewController]() { didSet { reload() } }
    
    var v = PagerView()
    
    override func loadView() {
        self.automaticallyAdjustsScrollViewInsets = false
        v.scrollView.delegate = self
        view = v
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        v.animateSelectorToPage(currentPage())
        refreshSelection()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pagerScrollViewDidScroll(scrollView)
        v.header.selector.leftConstraint?.constant =
            scrollView.contentOffset.x / CGFloat(controllers.count)
        UIView.animate(withDuration: 0.01, animations:v.layoutIfNeeded)
        if v.header.menuItems.count > 1 {
            let threshold: CGFloat = v.frame.size.width / CGFloat(v.header.menuItems.count)
            if scrollView.contentOffset.x > threshold {
                v.header.menuItems[0].unselect()
                v.header.menuItems[1].select()
            } else {
                v.header.menuItems[0].select()
                v.header.menuItems[1].unselect()
            }
        }
    }
    
    func reload() {
        let viewWidth: CGFloat = v.frame.width
        for (index, c) in controllers.enumerated() {
            
            addChildViewController(c)
            let x: CGFloat = CGFloat(index) * viewWidth
            c.view.frame = CGRect(x:x, y:0, width:viewWidth, height:v.frame.height)
            v.scrollView.addSubview(c.view)
        }
        
        let scrollableWidth: CGFloat = CGFloat(controllers.count) * CGFloat(viewWidth)
        v.scrollView.contentSize = CGSize(width:scrollableWidth, height:0)
        
        // Build headers
        for (index, c) in controllers.enumerated() {
            let menuItem = MenuItem()
            menuItem.text.text = c.title?.capitalized
            menuItem.button.tag = index
            menuItem.button.addTarget(self,
                                      action: #selector(tabTapped(_:)),
                                      for: .touchUpInside)
            v.header.menuItems.append(menuItem)
        }
        
        let currentMenuItem = v.header.menuItems[0]
        currentMenuItem.select()
        v.header.refreshMenuItems()
        
        //Adjsut seletor size
        v.header.selector.widthConstraint?.constant = v.frame.width / CGFloat(controllers.count)
    }
    
    func tabTapped(_ b: UIButton) {
        showPage(b.tag)
    }
    
    func showPage(_ page: Int) {
        v.animateSelectorToPage(page)
        let x = CGFloat(page) * UIScreen.main.bounds.width
        v.scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        selectPage(page)
    }
    
    func refreshSelection() {
        selectPage(currentPage())
    }
    
    func currentPage() -> Int {
        return Int(v.scrollView.contentOffset.x / v.frame.width)
    }
    
    func selectPage(_ page: Int) {
        //select menut item and deselect others
        for mi in v.header.menuItems {
            mi.unselect()
        }
        let currentMenuItem = v.header.menuItems[page]
        currentMenuItem.select()
        delegate?.pagerDidSelectController(controllers[page])
    }
}
