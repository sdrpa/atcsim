/**
 Created by Sinisa Drpa on 4/9/17.

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

import AircraftKit
import ATCKit
import Foundation
import Measure

extension Route {

    func calculatingTimestamps(first timestamp: TimeInterval, aircraft: Aircraft) -> Route {
        func time(from: Coordinate, to: Coordinate, speed: Kts) -> TimeInterval {
            let distance = Nm(from.distance(to: to))
            let t = distance.v / (speed.v/3600)
            //print("d: \(distance) => t: \(t/60)")
            return t
        }

        struct CoordinateInTime {
            let coordinate: Coordinate
            let timestamp: TimeInterval
        }
        // Lift navigation points to coordinates in time and use reduce to calculate timestamps
        let tmp = navigationPoints.map { CoordinateInTime(coordinate: $0.coordinate, timestamp: timestamp) }
        guard let firstCoordInTime = tmp.first,
            let mach = aircraft.performance.cruise.mach else {
                fatalError(#function)
        }
        let locations = tmp.dropFirst().reduce([firstCoordInTime]) { acc, current in
            guard let last = acc.last else { return acc }
            let t = time(from: last.coordinate, to: current.coordinate, speed: Kts(mach))
            return acc + [CoordinateInTime(coordinate: current.coordinate, timestamp: t + last.timestamp)]
        }
        let timestamps = locations.map { $0.timestamp }
        return Route(navigationPoints: navigationPoints, timestamps: timestamps)
    }
}
