//
//  RACExtensions.swift
//  Owners
//
//  Created by Ankit on 19/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

extension SignalProtocol {
	func merge(with signal2: Signal<Value, Error>) -> Signal<Value, Error> {
		return Signal { observer in
			let disposable = CompositeDisposable()
			disposable += self.observe(observer)
			disposable += signal2.observe(observer)
			return disposable
		}
	}
}

extension SignalProducerProtocol {
	func ignoreError() -> SignalProducer<Value, NoError> {
		return self.flatMapError { _ in
			SignalProducer<Value, NoError>.empty
		}
	}
	
	func delay(startAfter interval: TimeInterval, onScheduler scheduler: DateSchedulerProtocol)
		-> ReactiveSwift.SignalProducer<Value, Error>
	{
		return SignalProducer<(), Error>(value: ())
			.delay(interval, on: scheduler)
			.flatMap(.latest) { _ in self.producer }
	}
}

extension SignalProducerProtocol where Error == NoError {
	public func chain<U>(_ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
	}
	public func chain<U>(_ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return flatMap(.latest, transform: transform)
	}
	
	
	func chain<P: PropertyProtocol>( _ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0).producer }
	}
	
	func chain<U>( _ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? Signal<U, NoError>.never }
	}
	
	func chain<U>( _ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return flatMap(.latest) { transform($0) ?? SignalProducer<U, NoError>.empty }
	}
	
	func chain<P: PropertyProtocol>( _ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return flatMap(.latest) { transform($0)?.producer ?? SignalProducer<P.Value, NoError>.empty }
	}
	
	public func debounce( _ interval: TimeInterval, onScheduler scheduler: DateSchedulerProtocol) -> SignalProducer<Value, Error> {
		return flatMap(.latest, transform: { next in
			SignalProducer(value: next).delay(interval, on: scheduler)
		})
	}
}

extension PropertyProtocol {
	func chain<U>( _ transform: @escaping (Value) -> Signal<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>( _ transform: @escaping (Value) -> SignalProducer<U, NoError>) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyProtocol>( _ transform: @escaping (Value) -> P) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>( _ transform: @escaping (Value) -> Signal<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<U>( _ transform: @escaping (Value) -> SignalProducer<U, NoError>?) -> SignalProducer<U, NoError> {
		return producer.chain(transform)
	}
	
	func chain<P: PropertyProtocol>( _ transform: @escaping (Value) -> P?) -> SignalProducer<P.Value, NoError> {
		return producer.chain(transform)
	}
}
