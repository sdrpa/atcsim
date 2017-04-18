/**
 Created by Sinisa Drpa on 4/18/17.

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

// Created by Sinisa Drpa on 4/9/17.

import AircraftKit
import ATCKit
import Measure
import XCTest
@testable import ATCSIM

class RouteTests: XCTestCase {

    func testCalculatingTimestamps() {
        let p1 = Point(title: "RXD", coordinate: Coordinate(latitude: 42.300, longitude: 22.200))
        let p2 = Point(title: "VGN", coordinate: Coordinate(latitude: 42.700, longitude: 22.100))
        let p3 = Point(title: "NSI", coordinate: Coordinate(latitude: 43.300, longitude: 21.800))
        let p4 = Point(title: "BGD", coordinate: Coordinate(latitude: 44.800, longitude: 20.300))
        let p5 = Point(title: "BIT", coordinate: Coordinate(latitude: 45.900, longitude: 18.900))

        let aircraftDirectory = URL(fileURLWithPath: "\(#file)").deletingLastPathComponent().appendingPathComponent("../../../../Data/Aircraft")
        guard let aircraft = AircraftManager(directory: aircraftDirectory).aircraft(code: .B737) else {
            XCTFail(); return
        }

        let route = Route(navigationPoints: [p1, p2, p3, p4, p5])
            .calculatingTimestamps(first: 0, aircraft: aircraft)

        //let description = route.navigationPoints.enumerated().reduce([String]()) { acc, current in
        //    acc + [current.1.title + String(format: " at: %.1f", (route.timestamps?[current.0] ?? 0)/60)]
        //}
        //print(description)
        XCTAssertEqualWithAccuracy(Double(route.timestamps?.last ?? 0)/60, 30.3, accuracy: 0.1)

    }

    static var allTests = [
        ("testCalculatingTimestamps", testCalculatingTimestamps),
    ]
}
