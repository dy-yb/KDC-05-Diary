//
//  CollectionViewCell.swift
//  KDC-05-Diary
//
//  Created by Daye on 2022/03/10.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.contentView.layer.cornerRadius = 3.0
    self.contentView.layer.borderWidth = 1.0
    self.contentView.layer.borderColor = UIColor.black.cgColor
  }
}
