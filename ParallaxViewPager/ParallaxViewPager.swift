//
//  ParallaxViewPager.swift
//  ParallaxViewPager
//
//  Created by Ricardo on 17/11/16.
//  Copyright © 2016 Mobile First. All rights reserved.
//

import UIKit

public class ParallaxViewPager: UIScrollView, UIScrollViewDelegate {
    
    private static let SCROLLVIEW_VERTICAL = 0
    private static let SCROLLVIEW_HORIZONTAL = 1
    
    // container for the image pager
    private var imagesScrollView: UIScrollView!
    
    // imagesScrollView's height
    private var pagerHeight: CGFloat = 250
    
    // static image to be displayed
    private var staticImageView: UIImageView?
    
    // image names to be displayed
    private var imageNamesArray = [String]()
    
    // imageviews to be displayed
    private var imageViewsArray = [UIImageView]()
    
    // image scrollview page control
    private var pageControl: UIPageControl!
    
    // the initial offset in the scrollview
    private var initialOffsetY: CGFloat?
    
    // height to be used in the scrollview's content size
    private var navigationBarHeight: CGFloat = 0
    
    // height to be used in the scrollview's content size
    private var statusBarHeight: CGFloat {
        get {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    public init(frame: CGRect, pagerHeight: CGFloat, staticImageName: String, imageNames: [String]) {
        super.init(frame: frame)
        initWith(height: pagerHeight, staticImageName: staticImageName, imageNames: imageNames)
    }
    
    private func initUI() {
        initWith(height: nil, staticImageName: nil, imageNames: nil)
    }
    
    private func initWith(height: CGFloat?, staticImageName: String?, imageNames: [String]?) {
        self.delegate = self
        self.tag = ParallaxViewPager.SCROLLVIEW_VERTICAL
        self.showsVerticalScrollIndicator = false
        
        // update the view pager height
        if height != nil {
            self.pagerHeight = height!
        } else {
            self.pagerHeight = self.frame.size.height / 3
        }
        
        // update the image names array
        if imageNames != nil {
            self.imageNamesArray = imageNames!
        }
        
        // update the static image view
        if let imageName = staticImageName {
            self.staticImageView = UIImageView(image: UIImage(named: imageName))
        }
        
        // scrollview container for the images
        imagesScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.pagerHeight))
        imagesScrollView.delegate = self
        imagesScrollView.tag = ParallaxViewPager.SCROLLVIEW_HORIZONTAL
        imagesScrollView.showsHorizontalScrollIndicator = false
        
        // scrollview x offset
        var imageScrollXOffset: CGFloat = 0
        
        // add the imageviews
        for imageName in imageNamesArray {
            let imageView = UIImageView(frame: CGRect(
                x: imageScrollXOffset,
                y: 0,
                width: self.frame.size.width,
                height: self.pagerHeight)
            )
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            imagesScrollView.addSubview(imageView)
            imageViewsArray.append(imageView)
            
            imageScrollXOffset += imageView.frame.size.width
        }
        
        imagesScrollView.contentSize = CGSize(width: imageScrollXOffset, height: self.pagerHeight)
        imagesScrollView.isPagingEnabled = true
        
        addSubview(imagesScrollView)
        
        // add the static image
        
        
        // add the page control
        pageControl = UIPageControl(frame: CGRect(x: 0, y: pagerHeight-25, width: self.frame.size.width, height: 20))
        pageControl.numberOfPages = imageViewsArray.count
        if imageViewsArray.count > 1 {
            addSubview(pageControl)
        }
        
        // bring the first image to front
        if imageViewsArray.count > 0 {
            self.imagesScrollView.bringSubview(toFront: imageViewsArray[0])
        }
        self.imagesScrollView.bringSubview(toFront: pageControl)
        
        self.contentSize = CGSize(
            width: frame.size.width,
            height: self.pagerHeight
        )
    }
    
    public func addDetailView(view: UIView) {
        view.frame.origin.y = self.pagerHeight
        
        if view is UIScrollView {
            (view as! UIScrollView).isScrollEnabled = false
        }
        
        if view is UITableView {
            var tableHeight: CGFloat = 0
            
            let tableView = (view as! UITableView)
            let nRows = tableView.numberOfRows(inSection: 0)
            
            for i in 0...nRows-1 {
                let rect = tableView.rectForRow(at: IndexPath(row: i, section: 0))
                tableHeight += rect.size.height
            }
            
            tableView.frame = CGRect(
                x: tableView.frame.origin.x,
                y: tableView.frame.origin.y,
                width: tableView.frame.size.width,
                height: tableHeight)
            
        }
        
        self.addSubview(view)
        
        self.contentSize = CGSize(
            width: frame.size.width,
            height: self.contentSize.height + view.frame.size.height
        )
    }
    
    public func setNavigationBarHeight(value: CGFloat) {
        navigationBarHeight = value
        
        self.contentSize = CGSize(
            width: frame.size.width,
            height: self.contentSize.height
        )
    }
    
    public func addContentSizeExtraHeight(value: CGFloat) {
        self.contentSize = CGSize(
            width: frame.size.width,
            height: self.contentSize.height + value
        )
    }
    
    // MARK: Scroll view delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == ParallaxViewPager.SCROLLVIEW_VERTICAL {
            
            if initialOffsetY == nil {
                initialOffsetY = -scrollView.contentOffset.y
            }
            
            var frame = self.frame
            frame.size.height = -scrollView.contentOffset.y
            
            imagesScrollView.frame.origin.y = initialOffsetY! + scrollView.contentOffset.y
            
            let positiveOffset = -(initialOffsetY! + scrollView.contentOffset.y)
            imagesScrollView.frame.size.height = pagerHeight + positiveOffset
            
            for subview in imagesScrollView.subviews {
                
                if subview is UIImageView {
                    subview.frame = CGRect(
                        x: subview.frame.origin.x,
                        y: subview.frame.origin.y,
                        width: subview.frame.size.width,
                        height: imagesScrollView.frame.size.height
                    )
                }
                
            }
        }
            
        else if scrollView.tag == ParallaxViewPager.SCROLLVIEW_HORIZONTAL {
            
            let imageWidth: Double = Double(scrollView.frame.size.width)
            let fractionalPage: Double = Double(scrollView.contentOffset.x) / imageWidth
            let page = lround(fractionalPage)
            
            if imageViewsArray.count > page {
                self.imagesScrollView.bringSubview(toFront: imageViewsArray[page])
            }
            
            pageControl.currentPage = page
            self.imagesScrollView.bringSubview(toFront: pageControl)
        }
        
    }
    
}
