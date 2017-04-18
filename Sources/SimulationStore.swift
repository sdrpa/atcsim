/**
 Created by Sinisa Drpa on 2/16/17.

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

final class SimulationStore: StoreProtocol {
    typealias S = SimulationState

    fileprivate let store = Store<S>(initialState: SimulationState(), reducer: { state, action in
        switch action {
        case let action as Simulate:
            return action.reduce(state: state)
        case let action as AddFlight:
            return action.reduce(state: state)

        default:
            return state
        }
    })

    func subscribe(_ subscription: @escaping (S) -> Void) -> ((Void) -> Void) {
        return self.store.subscribe(subscription)
    }

    func dispatch(_ action: Action) {
        return self.store.dispatch(action)
    }

    var state: S {
        return self.store.state
    }
}
