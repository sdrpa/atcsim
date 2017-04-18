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
import Measure

struct SimulationState {

    let time: TimeInterval
    let flights: [Flight]

    init(time: TimeInterval = 0, flights: [Flight] = []) {
        self.time = time
        self.flights = flights
    }
}

extension SimulationState {

    func calculatingPositions(delta: TimeInterval) -> SimulationState {
        let flights: [Flight] = self.flights.map { flight in
            let futurePosition = flight.futurePosition(in: delta)
            return flight.updating(position: futurePosition)
        }
        return SimulationState(time: time + delta, flights: flights)
    }

    func adding(flight: Flight, time: TimeInterval) -> SimulationState {
        var flights = self.flights
        flights.append(flight)
        return SimulationState(time: time, flights: flights)
    }
}
