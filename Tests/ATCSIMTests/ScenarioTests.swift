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

// Created by Sinisa Drpa on 2/15/17.

import AirspaceKit
import ATCKit
import XCTest
@testable import ATCSIM

class ScenarioTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    var directory: URL {
        return URL(fileURLWithPath: "\(#file)").deletingLastPathComponent()
    }

    func testScenario() {
        let fileURL = directory.appendingPathComponent("One.txt")
        let dataURL = directory.appendingPathComponent("../../../../Data/")
        let airspaceURL = dataURL.appendingPathComponent("Airspace/Demo")
        guard let airspace = Airspace(directoryURL: airspaceURL) else {
            XCTFail(); return
        }
        let aircraftURL = dataURL.appendingPathComponent("Aircraft")
        guard let scenario = Scenario(fileURL: fileURL, airspace: airspace, aircraftURL: aircraftURL) else {
            XCTFail(); return
        }

        XCTAssertEqual("DLH123", scenario.flights.first?.flightPlan?.callsign)
        XCTAssertEqual("MAK443", scenario.flights.last?.flightPlan?.callsign)
    }

    static var allTests = [
        ("testScenario", testScenario)
    ]
}
