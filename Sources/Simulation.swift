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
import FDPS
import Foundation
import FoundationKit
import Measure

public final class Simulation {

    public var runningUpdate: ((_ newValue: Bool) -> Void)?
    public var timeUpdate: ((_ newValue: TimeInterval) -> Void)?
    public var speedUpdate: ((_ newValue: Int) -> Void)?
    public var simulationUpdate: (([FDPS.Flight]) -> Void)?

    public let scenario: Scenario

    fileprivate let store = SimulationStore()
    fileprivate var unsubscribe: (() -> Void)?

    fileprivate var metronome: Metronome?

    public var time: TimeInterval = 0 {
        didSet {
            self.timeUpdate?(self.time)
        }
    }
    public var speed: Int {
        set { self.metronome?.speed = newValue }
        get { return self.metronome?.speed ?? Metronome.minimumSpeed }
    }

    public init(scenario: Scenario) {
        self.scenario = scenario
        
        self.unsubscribe = self.store.subscribe(self.newState)

        for flight in scenario.flights {
            self.store.dispatch(SimulationStore.AddFlight(flight, time: time))
        }
        
        self.metronome = Metronome(event: self.simulate,
                                   runningChanged: { [weak self] isRunning in
                                    self?.runningUpdate?(isRunning)
            },
                                   speedChanged: { [weak self] newValue in
                                    self?.speedUpdate?(newValue)
            }
        )
    }

    deinit {
        self.unsubscribe?()
    }

    fileprivate func newState(_ state: SimulationState) {
        self.simulationUpdate?(state.flights.map {
            return FDPS.Flight(callsign: $0.callsign, squawk: $0.squawk, position: $0.position, mach: $0.mach, heading: $0.heading, flightPlan: $0.flightPlan)
        })
    }

    public func toggle() {
        self.metronome?.toggle()
    }

    public func reset() {
        self.metronome?.pause()
        self.time = 0
    }

    public func simulate(to time: TimeInterval) {
        let delta = time - self.time
        guard delta != 0 else { return }
        self.simulate(delta: delta)
    }

    fileprivate func simulate() {
        self.simulate(delta: 1)
    }

    fileprivate func simulate(delta: TimeInterval) {
        self.time += delta
        self.store.dispatch(SimulationStore.Simulate(delta: delta))
    }
}

fileprivate extension Simulation {

    func increaseTime(by interval: TimeInterval) {
        self.time += interval
    }

    func decreaseTime(by interval: TimeInterval) {
        self.time -= interval
    }
}

public extension Simulation {

    public var isRunning: Bool {
        return self.metronome?.isRunning ?? false
    }

    public static var minimumSpeed: Int {
        return Metronome.minimumSpeed
    }
    
    public static var maximumSpeed: Int {
        return Metronome.maximumSpeed
    }
}
