//
//  Tree.swift
//  EP Designer
//
//  Created by David Mann on 6/30/25.
//

import Foundation

struct Tree<Value: Hashable>: Hashable {
    let value: Value
    var children: [Tree]? = nil
}
