//
//  Home.swift
//
//
//  Created by Nigel Hughes on 7/2/23.
//

import Foundation

public protocol Home {
    var name  : String {get}
    
    var rooms : [any Room] {get}
    var zones : [any Zone] {get}
}
