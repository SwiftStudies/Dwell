//
//  Platform.swift
//
//
//  Created by Nigel Hughes on 7/8/23.
//

public protocol Platform {
    static var shared : Self { get }
    
    var authorized : Bool { get }
    
    var initialized : Bool { get }
    
    var homes : [Home] { get }
}


public enum SupportedPlatform : CaseIterable, Identifiable, CustomStringConvertible {
    public var id: String {
        return description
    }
    
    case HomeKit
    
    public var instance : Platform {
        switch self {
        case .HomeKit:
            return Dwell.HomeKit.shared
        }
    }
    
    public var description: String {
        switch self {
        case .HomeKit:
            return "HomeKit"
        }
    }
}
