//
//  PhotoExtensions.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation

extension Photo{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
