//
//  ObservedPublisher.swift
//  MySingleSoureOfTruthDemo
//
//  Created by Yang Xu on 2020/5/26.
//  Copyright © 2020 Yang Xu. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@propertyWrapper
struct ObservedPublisher<P:Publisher>:DynamicProperty where P.Failure == Never{
    private let publisher:P
    @State var cancellable:AnyCancellable? = nil
    
    @State public private(set) var wrappedValue:P.Output
    private var updateWrappedValue = MutableHeapWrapper<(P.Output)->Void>({ _ in })
    
    init(publisher:P,initial:P.Output) {
        self.publisher = publisher
        self._wrappedValue = .init(wrappedValue: initial)
        
        let updateWrappedValue = self.updateWrappedValue
        self._cancellable = .init(initialValue:  publisher
            .delay(for: .nanoseconds(1), scheduler: RunLoop.main)
            .sink(receiveValue: {
                updateWrappedValue.value($0)
            }))
    }
    
    public mutating func update() {
        let _wrappedValue = self._wrappedValue
        updateWrappedValue.value = {
            _wrappedValue.wrappedValue = $0}
    }
    
}

public final class MutableHeapWrapper<T> {
    public var value: T
    
    @inlinable
    public init(_ value: T) {
        self.value = value
    }
}
