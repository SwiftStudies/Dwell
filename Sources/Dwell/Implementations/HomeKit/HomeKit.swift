//
//  HomeKit.swift
//
//
//  Created by Nigel Hughes on 7/2/23.
//

import HomeKit

enum HomeKitError : Error {
    case notAuthorized(status: HMHomeManagerAuthorizationStatus)
}

public struct HomeKit {
    
    static internal var delegate : HomeKitDelegate? = nil
    
    public static func home(named name:String) async throws -> Home?{
        guard let delegate else {
            delegate = HomeKitDelegate()
            try await Task.sleep(for: .seconds(1))
            return try await home(named: name)
        }
     
        guard let authorizationStatus = delegate.authorizationStatus else {
            try await Task.sleep(for: .seconds(1))
            return try await home(named: name)
        }
        
        if !authorizationStatus.contains(.authorized) {
            throw HomeKitError.notAuthorized(status: authorizationStatus)
        }
        
        guard delegate.homesUpdatedOnce else {
            try await Task.sleep(for: .seconds(1))
            return try await home(named: name)
        }
        
        for home in delegate.manager.homes {
            if home.name == name {
                return Implementation<HMHome>(implementedBy: home)
            }
        }
        
        return nil
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
