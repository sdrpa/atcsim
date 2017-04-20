
// Created by Sinisa Drpa on 2/17/17.
// https://github.com/fellipecaetano/Redux.swift

/**
 Copyright (c) 2016 Fellipe Caetano <fellipe.caetano4@gmail.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

/**
 Functions meant for execution whenever actions are dispatched from a store. 
 The first parameter is an accessor for the aforementioned store's state when 
 the middleware is run, and the second parameter is the action that triggered 
 the execution.
 */
public typealias Middleware<State> = (@escaping (() -> State), Action) -> Void

/// A pure function that is responsible for transforming state according to action
public typealias Reducer<State> = (State, Action) -> State

/**
 The data structure responsible for holding application state, allowing 
 controlled mutation through dispatched `Actions` and notifying interested 
 parties that `subscribe` to state changes.
 */
public final class Store<State>: StoreProtocol {

    fileprivate let reducer: Reducer<State>

    public private(set) var state: State {
        didSet {
            self.publish(state)
        }
    }

    /// Key is a subscription token, value is a closure called whenever a new
    /// state is available
    fileprivate var subscribers: [String: (State) -> Void]
    fileprivate let middleware: [Middleware<State>]

    /**
     Initializes a `Store`.

     - parameter initialState: The initial value of the application state in hold.
     - parameter middleware: A collection of functions that will be run whenever
        an `Action` is dispatched.
     - parameter reducer: The root pure function that's responsible for
        transforming state according to `Actions`.
     */
    public init (initialState: State, reducer: @escaping Reducer<State>, middleware: [Middleware<State>] = []) {
        self.state = initialState
        self.middleware = middleware
        self.reducer = reducer
        self.subscribers = [:]
    }

    /**
     Perform state changes described by the action and the root reducer.

     - parameter action: The descriptor of **what** is the state change.
     */
    public func dispatch(_ action: Action) {
        for middleware in self.middleware {
            middleware({ self.state }, action)
        }
        self.state = self.reducer(state, action)
    }

    /**
     Registers a handler that's called when state changes

     - parameter subscription: A closure called whenever there's a change to the state.
     - returns: A closure that unsubscribes the provided subscription.
     */
    public func subscribe(_ subscription: @escaping (State) -> Void) -> (() -> Void) {
        let token = UUID().uuidString
        self.subscribers[token] = subscription

        subscription(self.state)

        return { [weak self] in
            _ = self?.subscribers.removeValue(forKey: token)
        }
    }

    fileprivate func publish(_ newState: State) {
        self.subscribers.values.forEach { $0(newState) }
    }
}

/**
 Defines `Action` dispatch capabilities. Instances conforming to `Dispatcher` are expected to know how to
 dispatch `Actions`.
 */

public protocol Dispatcher {
    /**
     Dispatches an action.

     - parameter action: The action that'll be dispatched.
     */
    func dispatch(_ action: Action)
}

/**
 Defines a mutation descriptor. Are typically associated to application actions and operations.
 */
public protocol Action {
}

/**
 Instances conforming to `Publisher` are expected to know how to add handlers that are provided with an associated
 object in response to generic events.
 */
public protocol Publisher {
    associatedtype State

    /**
     Adds a handler to a generic event.

     - parameter subscription: The handler that will be called in response to generic events.
     - returns: A closure that unsubscribes the provided subscription.
     */
    func subscribe(_ subscription: @escaping (State) -> Void) -> (() -> Void)
}

/**
 Defines behavior exposed by a Redux store, i. e. action dispatching capabilities
 and notifications of state changes to subscribers.
 */
public protocol StoreProtocol: Publisher, Dispatcher {
    /**
     Returns the current `State` of the store.
     */
    var state: State { get }
}

/**
 A type-erased `StoreProtocol` conformance.
 */
public struct AnyStore<T>: StoreProtocol {

    private let doSubscribe: (@escaping (T) -> Void) -> (() -> Void)
    private let doDispatch: (Action) -> Void
    private let getState: () -> T

    fileprivate init (subscribe: @escaping (@escaping (T) -> Void) -> (() -> Void),
                      dispatch: @escaping (Action) -> Void,
                      getState: @escaping () -> T) {
        self.doSubscribe = subscribe
        self.doDispatch = dispatch
        self.getState = getState
    }

    public func subscribe(_ subscription: @escaping (T) -> Void) -> (() -> Void) {
        return self.doSubscribe(subscription)
    }

    public func dispatch(_ action: Action) {
        self.doDispatch(action)
    }

    public var state: T {
        return self.getState()
    }
}
