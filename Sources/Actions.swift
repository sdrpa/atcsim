/**
 Created by Sinisa Drpa on 4/1/17.

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

protocol SIMAction: Action {
    var timestamp: TimeInterval { get }
    func reduce(oldState: State) -> State
}

extension MainStore {

    struct calculate: SIMAction {
        var timestamp: TimeInterval
        let delta: TimeInterval

        init(_ delta: TimeInterval, at: TimeInterval) {
            self.timestamp = at
            self.delta = delta
        }
        
        func reduce(oldState: State) -> State {
            print("Calculate at: \(timestamp)")
            return oldState.calculating(delta: delta)
        }
    }

    struct addFlight: SIMAction {
        var timestamp: TimeInterval
        let flight: Flight

        init(_ flight: Flight, at: TimeInterval) {
            self.timestamp = at
            self.flight = flight
        }

        func reduce(oldState: State) -> State {
            print("AddFlight at: \(timestamp)")
            return oldState.adding(flight: flight, at: timestamp)
        }
    }
}
