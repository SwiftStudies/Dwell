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
    
    public var authorized : Bool {
        return delegate.authorizationStatus?.contains(.authorized) ?? false
    }
    
    public var initializaed : Bool {
        return authorized && delegate.homesUpdatedOnce
    }
    
    public var homes : [Home] {
        return delegate.manager.homes.map{
            HomeKitHome(implementedBy: $0)
        }
    }
    
    fileprivate init(){
        delegate = HomeKitDelegate()
    }
}

class HomeKitDelegate : NSObject, HMHomeManagerDelegate {
    let manager : HMHomeManager
    
    var authorizationStatus : HMHomeManagerAuthorizationStatus?
    
    var homesUpdatedOnce = false
    
    override init(){
        manager = HMHomeManager()
        super.init()

        manager.delegate = self
    }
    
    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        authorizationStatus = status
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        homesUpdatedOnce = true
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
