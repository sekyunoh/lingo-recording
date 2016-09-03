//
//  SectionCell.swift
//  Shelf
//
//  Created by Hirohisa Kawasaki on 8/8/15.
//  Copyright (c) 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

public class SectionCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var collectionView: UICollectionView!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    collectionView.clipsToBounds = false
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    titleLabel.layer.masksToBounds = true
    titleLabel.layer.cornerRadius = 6
    let bundle = NSBundle(forClass: ItemCell.self)
    collectionView.registerNib(UINib(nibName: "ItemCell", bundle: bundle), forCellWithReuseIdentifier: "ItemCell")
  }
  
}