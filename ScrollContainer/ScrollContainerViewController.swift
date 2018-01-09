//
//  ScrollContainer.swift
//  ScrollContainer
//
//  Created by YE on 2018/1/9.
//  Copyright © 2018年 Eter. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ScrollContainerDelegate {
    func didShowViewController(at index: Int)
}

class ScrollContainerViewController: UIViewController
{
    fileprivate struct Constant {
        static let titleScrollViewHeight: CGFloat = 44.0
        static let titleScrollViewBgColor: UIColor = UIColor.groupTableViewBackground
        static let heightLightColor = UIColor(red: 0x02/255.0, green: 0x74/255.0, blue: 0xae/255.0, alpha: 1)
    }
    
    fileprivate var titleScrollView: UIScrollView!
    fileprivate var contentScrollView: UIScrollView!
    fileprivate var targetWidth: CGFloat { return self.view.frame.size.width }
    fileprivate var targetHeight: CGFloat { return self.view.frame.size.height }
    fileprivate var line: UIView!
    fileprivate var titleLabels: [UILabel]!
    fileprivate var lableW: CGFloat = 0
    fileprivate var selectedLabel: UILabel?
    
    var delegate: ScrollContainerDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        delegate = self as? ScrollContainerDelegate
        
        titleScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: targetWidth, height: Constant.titleScrollViewHeight))
        titleScrollView.showsVerticalScrollIndicator = false
        titleScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.backgroundColor = Constant.titleScrollViewBgColor
        self.view.addSubview(titleScrollView)
        
        contentScrollView = UIScrollView(frame: CGRect(x: 0, y: Constant.titleScrollViewHeight, width: targetWidth, height: targetHeight-Constant.titleScrollViewHeight))
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.isPagingEnabled = true
        self.view.addSubview(contentScrollView)
    }
    
    var viewControllers: [UIViewController]! {
        didSet {
            setupChildViewController()
            setupTitleLabel()
            setupScrollView()
        }
    }
    
    fileprivate func setupChildViewController() {
        _ = viewControllers.map() { (vc) -> Swift.Void in
            self.addChildViewController(vc)
        }
    }
    
    fileprivate func setupTitleLabel() {
        let count = self.childViewControllers.count
        lableW = count <= 5 ? targetWidth / CGFloat(count) : targetWidth / 5
        
        var labelX: CGFloat = 0
        let labelY: CGFloat = 0
        let labelH: CGFloat = Constant.titleScrollViewHeight-1
        
        line = UIView(frame: CGRect(x: labelX, y: labelH, width: lableW, height: 1))
        line.backgroundColor = Constant.heightLightColor
        titleScrollView.addSubview(line)
        
        for index in 0..<count {
            
            let vc = self.childViewControllers[index]
            let label = UILabel()
            labelX = CGFloat(index) * lableW
            label.frame = CGRect(x: labelX, y: labelY, width: lableW, height: labelH)
            label.text = vc.title
            label.highlightedTextColor = Constant.heightLightColor
            label.tag = index
            label.isUserInteractionEnabled = true
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.3
            if titleLabels == nil {
                titleLabels = [UILabel]()
            }
            titleLabels.append(label)
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleClick(sender:)))
            label.addGestureRecognizer(tap)
            
            if index == 0 {
                titleClick(sender: tap)
            }
            titleScrollView.addSubview(label)
        }
    }
    
    fileprivate  func setupScrollView() {
        let count = self.childViewControllers.count
        
        titleScrollView.contentSize = CGSize(width: lableW * CGFloat(count), height: 0)
        
        contentScrollView.contentSize = CGSize(width: CGFloat(count) * targetWidth, height: 0)
        contentScrollView.delegate = self
    }
    
    fileprivate func selectView(label: UILabel) {
        
        selectedLabel?.isHighlighted = false
        label.isHighlighted = true
        selectedLabel?.textColor = UIColor.black
        selectedLabel = label
    }
    
    fileprivate func showVc(index: Int) {
        let offsetX = CGFloat(index)*targetWidth
        let vc = self.childViewControllers[index]
        delegate?.didShowViewController(at: index)
        
        if contentScrollView.subviews.contains(vc.view) {
            return
        }
        if let ct = vc.navigationController {
            ct.navigationBar.isTranslucent = false
        }
        vc.view.frame = CGRect(x: offsetX, y: 0, width: contentScrollView.bounds.size.width, height: contentScrollView.bounds.size.height)
        contentScrollView.addSubview(vc.view)
    }
    
    fileprivate func setupTitleCenter(label: UILabel) {
        var offsetX = label.center.x - targetWidth * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        
        let maxOffsetX = titleScrollView.contentSize.width - targetWidth
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        
        titleScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
}
extension ScrollContainerViewController: UIScrollViewDelegate
{

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        let index: Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.showVc(index: index)
        
        let selLabel = self.titleLabels[index]
        self.selectView(label: selLabel)
        self.setupTitleCenter(label: selLabel)
        UIView.animate(withDuration: 0.5) {
            self.line.frame.origin.x = selLabel.frame.origin.x
            self.line.frame.size.width = selLabel.frame.size.width
        }

    }
    @objc func titleClick(sender: UITapGestureRecognizer) {
        
        if let label = sender.view as? UILabel {
            
            self.selectView(label: label)
            
            let index = label.tag
            
            let offsetX = CGFloat(index)*self.targetWidth
            UIView.animate(withDuration: 0.5) {
                self.contentScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
            }
            self.showVc(index: index)
            self.setupTitleCenter(label: label)
            
            UIView.animate(withDuration: 0.5) {
                self.line.frame.origin.x = label.frame.origin.x
                self.line.frame.size.width = label.frame.size.width
            }
        }

    }
    
}


