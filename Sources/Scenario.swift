/**
 Created by Sinisa Drpa on 2/15/17.

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

import Foundation

import AircraftKit
import AirspaceKit
import ATCKit
import Measure

public struct Scenario: CustomStringConvertible {

    public let fileURL: URL?
    public var title: String? {
        return self.fileURL?.deletingPathExtension().lastPathComponent ?? nil
    }
    let flights: [Flight]

    public var description: String {
        return "Flights: \(self.flights.count)"
    }

    public init?(fileURL: URL, airspace: Airspace, aircraftURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        self.fileURL = fileURL
        let flights = Scenario.parseFlights(fileURL: fileURL, airspace: airspace, aircraftURL: aircraftURL)
            ?? [Flight]()
        self.flights = flights
    }

    fileprivate static func parseFlights(fileURL: URL, airspace: Airspace, aircraftURL: URL) -> [Flight]? {
        let aircraftManager = AircraftManager(directory: aircraftURL)
        var flights = [Flight]()

        func parseRoute(string: String) -> [NavigationPoint]? {
            let route = string.components(separatedBy: " ").reduce([NavigationPoint]()) { acc, title in
                guard let point = airspace.navigationPoint(title: title) else {
                    return acc
                }
                return acc + [point]
            }
            return route
        }

        func parseCoordinate(string: String) -> Coordinate? {
            let components = string.components(separatedBy: "/")
            switch components.count {
            case 1: return airspace.navigationPoint(title: components[0])?.coordinate
            // TODO: Calculate coordinate for RAXAD/360/10
            case 3: return airspace.navigationPoint(title: components[0])?.coordinate
            default:
                return nil
            }
        }

        func parseFL(string: String) -> FL? {
            if string.hasPrefix("F") {
                let substring = string.substring(from: string.index(string.startIndex, offsetBy: 1))
                return FL(substring)
            }
            if string.hasPrefix("A") {
                let substring = string.substring(from: string.index(string.startIndex, offsetBy: 1))
                return FL(Feet(substring))
            }
            return nil
        }

        func parseETOF(string: String) -> TimeInterval? {
            let joined = string.components(separatedBy: ".").joined()
            return TimeInterval(joined)
        }

        func parseFlight(lines: [String]) -> Flight? {
            var callsign: String?
            var accode: String?
            var squawk: Squawk?
            var ADEP: String?
            var ADES: String?
            var coordinate: Coordinate?
            var AFL: FL?
            var CFL: FL?
            var RFL: FL?
            var points: [NavigationPoint]?
            var ETOF: TimeInterval?

            for line in lines {
                let components = line.components(separatedBy: ":")
                guard components.count == 2 else {
                    return nil
                }
                let attribute = components[0]
                let value = components[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                switch attribute {
                case "CS": callsign = value
                case "ACF": accode = value
                case "SQUAWK": squawk = UInt(value)
                case "ADEP": ADEP = value
                case "ADES": ADES = value
                case "CORD": coordinate = parseCoordinate(string: value)
                case "AFL": AFL = parseFL(string: value)
                case "CFL": CFL = parseFL(string: value)
                case "RFL": RFL = parseFL(string: value)
                case "ROUTE": points = parseRoute(string: value)
                case "ETOF": ETOF = parseETOF(string: value)
                default:
                    return nil
                }
            }

            guard let cs = callsign else { return nil }
            guard let type = accode else { return nil }
            guard let code = Aircraft.ICAOCode(rawValue: type) else { return nil }
            guard let aircraft = aircraftManager.aircraft(code: code) else { return nil }
            guard let thesquawk = squawk else { return nil }
            guard let adep = ADEP else { return nil }
            guard let ades = ADES else { return nil }
            guard let coord = coordinate else { return nil }
            guard let timestamp = ETOF else { return nil }
            guard let afl = AFL else { return nil }
            let position = Position(coordinate: coord, altitude: Feet(afl))
            guard let cfl = CFL else { return nil }
            guard let rfl = RFL else { return nil }
            guard let pts = points else { return nil }

            let route = Route(navigationPoints: pts).calculatingTimestamps(first: timestamp, aircraft: aircraft)
            let flightPlan = FlightPlan(callsign: cs,
                                        squawk: thesquawk,
                                        aircraft: aircraft,
                                        ADEP: adep,
                                        ADES: ades,
                                        RFL: rfl,
                                        route: route)

            guard let firstPoint = route.navigationPoints.first,
                let secondPoint = route.nextPointOnRoute(after: firstPoint) else {
                fatalError(#function)
            }
            let heading: Degree
            if position.coordinate ~= firstPoint.coordinate {
                heading = position.coordinate.bearing(to: firstPoint.coordinate)
            } else {
                heading = position.coordinate.bearing(to: secondPoint.coordinate)
            }

            let flight = Flight(callsign: cs, squawk: thesquawk, position: position, mach: aircraft.performance.cruise.mach ?? 0.78, heading: heading, clearedFL: cfl, flightPlan: flightPlan)
            return flight
        }

        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            var lines = [String]()
            contents.enumerateLines { line, _ in
                if line.hasPrefix("ETOF") { // ETOF is the last attribute
                    lines.append(line)
                    if let flight = parseFlight(lines: lines) {
                        flights.append(flight)
                    }
                    lines = [String]()
                    return
                }
                if line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count != 0 {
                    lines.append(line)
                }
            }
            return flights
        } catch {
            return nil
        }
    }
}

fileprivate extension FL {

    init?(_ string: String) {
        guard let v = Int(string) else {
            return nil
        }
        self.init(v)
    }

    init?(_ feet: Feet?) {
        guard let v = feet else {
            return nil
        }
        self.init(v)
    }
}

fileprivate extension Feet {

    init?(_ string: String) {
        guard let v = Int(string) else {
            return nil
        }
        self.init(v)
    }
}
