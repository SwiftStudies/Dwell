//
//  HomeKit.swift
//
//
//  Created by Nigel Hughes on 7/2/23.
//

import HomeKit
import SwiftUI

public enum HomeKitError : Error {
    case notAuthorized(status: HMHomeManagerAuthorizationStatus)
}

@available(macCatalyst 17, iOS 17, tvOS 17, *)
fileprivate let _homeKit : HomeKit = {
    return HomeKit()
}()

@available(macCatalyst 17, iOS 17, tvOS 17, *)
@Observable public class HomeKit : Platform {
    public static var shared : Self {
        return _homeKit as! Self
    }
    
    internal let delegate : HomeKitDelegate
    
    fileprivate var _authorized = false

    public var authorized : Bool {
        return _authorized
    }
    
    fileprivate var _initialized = false
    
    public var initialized : Bool {
        return authorized || _initialized
    }
    
    fileprivate var _homes = [Home]()
    
    public var homes : [Home] {
        return _homes
    }
    
    fileprivate init(){
        delegate = HomeKitDelegate()
    }
}

class HomeKitDelegate : NSObject, HMHomeManagerDelegate {
    let manager : HMHomeManager

    override init(){
        manager = HMHomeManager()
        super.init()

        manager.delegate = self
    }
    
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        _homeKit._authorized = status.contains(.authorized)
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        _homeKit._initialized = true
        _homeKit._homes = manager.homes.sorted(by: { lhs, rhs in
            if lhs.isPrimary { return true }
            if rhs.isPrimary { return false }
            return lhs.name < rhs.name
        }).map{
            HomeKitHome(implementedBy: $0)
        }
    }
}

typealias HomeKitHome = Implementation<HMHome>
extension Implementation : Home where NativeType == HMHome  {
    var name : String {
        return nativeImplementation.name
    }
    
    var rooms : [Room] {
        return nativeImplementation.rooms.map({HomeKitRoom(implementedBy: $0)})
    }
    
    var zones : [Zone] {
        return nativeImplementation.zones.map({HomeKitZone(implementedBy: $0)})
    }

}

typealias HomeKitRoom = Implementation<HMRoom>
extension Implementation : Room where NativeType == HMRoom {
    var name : String {
        return nativeImplementation.name
    }
}

typealias HomeKitZone = Implementation<HMZone>
extension Implementation : Zone where NativeType == HMZone {
    var name : String {
        return nativeImplementation.name
    }
}
