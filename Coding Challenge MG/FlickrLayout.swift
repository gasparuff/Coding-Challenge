    //
//  FlickrLayout.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 20/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit

protocol FlickrLayoutDelegate {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                        withWidth:CGFloat) -> CGFloat
}

    
class FlickrLayout: UICollectionViewLayout {

    var delegate: FlickrLayoutDelegate!
    
    var numberOfColumns = Config.NumberOfColumns
    var cellPadding: CGFloat = 6.0

    private var cache = [UICollectionViewLayoutAttributes]()
    private var loadingCellCache = [UICollectionViewLayoutAttributes]()
    private var yOffset : [CGFloat]!

    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    private var lastPagerYOffset : CGFloat?
    
    override func prepareLayout() {
        if collectionView?.numberOfSections() > 0 && cache.count < collectionView?.numberOfItemsInSection(0){
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            for item in cache.count ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                let width = columnWidth - cellPadding * 2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath,
                                                          withWidth:width)
                
                let height = cellPadding +  photoHeight + cellPadding
                
                //Finding the column with the most-upper last element, otherwise photos with bigger heights could lead to one column growing much higher than the other ones
                let minimumYOffsetIndex = yOffset.indexOf(yOffset.minElement()!)!
                
                let frame = CGRect(x: xOffset[minimumYOffsetIndex], y: yOffset[minimumYOffsetIndex], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[minimumYOffsetIndex] = yOffset[minimumYOffsetIndex] + height

            }
            if collectionView!.numberOfSections() > 1 {
                for item in 0 ..< collectionView!.numberOfItemsInSection(1) {
                    
                    let indexPath = NSIndexPath(forItem: item, inSection: 1)
                    
                    // 4
                    let width = contentWidth
                    let pagerHeight : CGFloat = 80
                    
                    let height = cellPadding + pagerHeight + cellPadding
                    
                    let maximumYOffsetIndex = yOffset.indexOf(yOffset.maxElement()!)!
                    
                    lastPagerYOffset = yOffset[maximumYOffsetIndex] + height
                    
                    let frame = CGRect(x: xOffset[0], y: yOffset[maximumYOffsetIndex], width: width, height: height)
                    let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    attributes.frame = insetFrame
                    loadingCellCache = [UICollectionViewLayoutAttributes]()
                    loadingCellCache.append(attributes)
                    
                    contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                }
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        for attributes in loadingCellCache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    // This is needed for resetting values after a new search was done
    func resetCache(){
        cache = [UICollectionViewLayoutAttributes]()
        loadingCellCache = [UICollectionViewLayoutAttributes]()
        contentHeight = 0.0
        yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
        
    }
}
