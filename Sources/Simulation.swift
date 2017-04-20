/**
 Created by Sinisa Drpa on 2/10/17.

 ATCSIM is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License or any later version.

 ATCSIM is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with ATCSIM.  If not, see <http://www.gnu.org/licenses/>
 */

import ATCKit
import Foundation
import FoundationKit
import Measure

public final class Simulation {

    public var runningUpdate: ((_ newValue: Bool) -> Void)?
    public var speedUpdate: ((_ newValue: Int) -> Void)?
    public var simulationUpdate: ((SimulationResult) -> Void)?

    public let scenario: Scenario

    fileprivate let store = MainStore()
    fileprivate var unsubscribe: (() -> Void)?
    fileprivate var cache: [State] = []

    fileprivate var metronome: Metronome?

    private var _timestamp: TimeInterval = 0
    public var timestamp: TimeInterval {
        set {
            if let cached = cache.first(where: { $0.timestamp == newValue }) {
                //print("\(newValue) read from cache")
                // If we have state in cache use the cached version
                stateDidUpdate(cached)
                let action = MainStore.setState(cached, at: newValue)
                store.dispatch(action)
            } else {
                // We don't have cached version for the given timestamp, we need to
                // calculate up to the timestamp
                //print("\(newValue) has to be calculated")
                let oldValue = _timestamp
                let delta = newValue - oldValue
                let action = MainStore.calculate(delta, at: newValue)
                store.dispatch(action)
            }
            _timestamp = newValue
        }
        get {
            return _timestamp
        }
    }
    public var speed: Int {
        set { metronome?.speed = newValue }
        get { return metronome?.speed ?? Metronome.minimumSpeed }
    }

    public init(scenario: Scenario) {
        self.scenario = scenario
        
        self.unsubscribe = store.subscribe(stateDidUpdate)

        for flight in scenario.flights {
            let action = MainStore.addFlight(flight, at: timestamp)
            store.dispatch(action)
        }
        
        self.metronome = Metronome(
            event: { [weak self] in
                self?.timestamp += 1
            },
            runningChanged: { [weak self] isRunning in
                self?.runningUpdate?(isRunning)
            },
            speedChanged: { [weak self] newValue in
                self?.speedUpdate?(newValue)
            }
        )
    }

    deinit {
        unsubscribe?()
    }

    public func toggle() {
        metronome?.toggle()
    }

    public func reset() {
        metronome?.pause()
        timestamp = 0
    }
}

fileprivate extension Simulation {

    fileprivate func stateDidUpdate(_ state: State) {
        cache.append(state)
        simulationUpdate?(SimulationResult(state: state))
    }
}

fileprivate extension Simulation {

    func increaseTime(by interval: TimeInterval) {
        timestamp += interval
    }

    func decreaseTime(by interval: TimeInterval) {
        timestamp -= interval
    }
}

public extension Simulation {

    public var isRunning: Bool {
        return metronome?.isRunning ?? false
    }

    public static var minimumSpeed: Int {
        return Metronome.minimumSpeed
    }
    
    public static var maximumSpeed: Int {
        return Metronome.maximumSpeed
    }
}
