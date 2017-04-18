/**
 Created by Sinisa Drpa on 2/6/17.

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
import Measure

/**
 * Flight != FDPS.Flight. Flight inside ATCSIM module is internal, used for simulation.
 */
struct Flight: Equatable {

    let callsign: String
    let squawk: Squawk
    let position: Position
    let mach: Mach
    let heading: Degree
    let clearedFL: FL
    let flightPlan: FlightPlan?

    init(callsign: String, squawk: Squawk = 2000, position: Position, mach: Mach, heading: Degree, clearedFL: FL? = nil, flightPlan: FlightPlan?) {
        self.callsign = callsign
        self.squawk = squawk
        self.position = position
        self.mach = mach
        self.heading = heading
        self.clearedFL = FL(position.altitude)
        self.flightPlan = flightPlan
    }

    static func ==(lhs: Flight, rhs: Flight) -> Bool {
        return (lhs.callsign == rhs.callsign) && (lhs.squawk == rhs.squawk)
    }
}

extension Flight {

    func nextPointOnRoute(from position: Position) -> NavigationPoint? {
        guard let flightPlan = flightPlan,
            let nearestPoint = flightPlan.route.nearestPointOnRoute(from: position.coordinate),
            let indexOfNearestPoint = flightPlan.route.navigationPoints.index(of: AnyNavigationPoint(nearestPoint)) else {
                return nil
        }
        let turnLimit = Degree(45) // If we need to turn more then 45°, choose next point
        let subroute = flightPlan.route.navigationPoints[indexOfNearestPoint..<flightPlan.route.navigationPoints.count]
        let nextPoint = subroute.first {
            let diff = heading.distance(to: position.coordinate.bearing(to: $0.coordinate))
            return diff < turnLimit
        }
        guard let np = nextPoint else {
            return flightPlan.route.navigationPoints.last
        }
        return np
    }

    func time(from: Coordinate, to: Coordinate, speed: Kts) -> TimeInterval {
        let distance = from.distance(to: to)
        let t = Nm(distance).v / (speed.v/3600)
        return t
    }
}
