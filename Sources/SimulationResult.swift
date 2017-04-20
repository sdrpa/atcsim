/**
 Created by Sinisa Drpa on 4/20/17.

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

import FDPS
import Foundation

/// SimulationResult is similar to State. State uses internal Flight type
/// while SimulationResult uses FDPS.Flight. See Flight.swift for more.
public struct SimulationResult {

    public let timestamp: TimeInterval
    public let flights: [FDPS.Flight]

    init(state: State) {
        self.timestamp = state.timestamp
        self.flights = state.flights.map { FDPS.Flight($0) }
    }
}

fileprivate extension FDPS.Flight {

    init(_ flight: Flight) {
        self.callsign = flight.callsign
        self.squawk = flight.squawk
        self.position = flight.position
        self.mach = flight.mach
        self.heading = flight.heading
        self.flightPlan = flight.flightPlan
    }
}
