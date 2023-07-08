//
//  HomeKit.swift
//
//
//  Created by Nigel Hughes on 7/2/23.
//

import Foundation

internal struct Implementation<NativeType>  {
    internal let nativeImplementation : NativeType
    
    internal init(implementedBy nativeInstance:NativeType){
        self.nativeImplementation = nativeInstance
    }
}
