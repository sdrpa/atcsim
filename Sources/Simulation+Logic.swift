/**
 Created by Sinisa Drpa on 4/7/17.

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

extension Flight {

    func futurePosition(in delta: TimeInterval) -> Position {
        let v = Kts(mach).v
        let distance = Meter(Nm(v/3600.0 * delta))
        guard let nextPoint = nextPointOnRoute(from: position) else {
            return position
        }
        let coordinate = position.coordinate
        let heading = coordinate.bearing(to: nextPoint.coordinate)
        let newCoordinate = coordinate.coordinate(at: distance, bearing: heading)
        return Position(coordinate: newCoordinate, altitude: position.altitude)
    }

    func updating(position newPosition: Position) -> Flight {
        let heading = position.coordinate.bearing(to: newPosition.coordinate)
        return Flight(callsign: callsign, squawk: squawk, position: newPosition, mach: mach, heading: heading, flightPlan: flightPlan)
    }
}
