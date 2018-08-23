//
//  TruckDetailController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 8/21/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit

class TruckDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var foodTruck: FoodTruck? {
        didSet {
            navigationItem.title = foodTruck?.name
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        // Register Header
        
        let headerNib = UINib(nibName: "TruckDetailHeader", bundle: nil)
        
        collectionView?.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        let footerNib = UINib(nibName: "TruckDetailFooter", bundle: nil)
        collectionView?.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerId")
        // Register Photo Cell
        // Register Menu Cell
        // Register Review Cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "UICollectionElementKindSectionHeader" {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! TruckDetailHeader
        
        header.foodTruck = foodTruck

        // To do: set header delegate
        return header
        } else if kind == "UICollectionElementKindSectionFooter" {
        
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerId", for: indexPath) as! TruckDetailFooter
            
            // To DO: set footer delegate
            
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
