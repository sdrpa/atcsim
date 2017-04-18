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

extension SimulationStore {
    typealias State = SimulationState

    struct Simulate: Action {
        let delta: TimeInterval

        func reduce(state: State) -> State {
            return state.calculatingPositions(delta: delta)
        }
    }

    struct AddFlight: Action {
        let flight: Flight
        let time: TimeInterval

        init(_ flight: Flight, time: TimeInterval) {
            self.flight = flight
            self.time = time
        }

        func reduce(state: State) -> State {
            return state.adding(flight: flight, time:  time)
        }
    }
}
