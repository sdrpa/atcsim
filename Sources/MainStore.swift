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

final class MainStore: StoreProtocol {

    static let initialState = State()
    var recorded: [SIMAction] = []

    static let reducer: Reducer<State> = { state, action in
        switch action {
        case let action as SIMAction:
            return action.reduce(oldState: state)
        default:
            return state
        }
    }

    fileprivate let store = Store<State>(initialState: MainStore.initialState,
                                         reducer: MainStore.reducer)

    // Publisher
    func subscribe(_ subscription: @escaping (State) -> Void) -> ((Void) -> Void) {
        return self.store.subscribe(subscription)
    }

    // Dispatcher
    func dispatch(_ action: Action) {
        self.store.dispatch(action)

        guard let action = action as? SIMAction else {
            print("Action must be SIMAction to be recorded.")
            return
        }
        self.record(action: action)
    }

    // StoreProtocol
    var state: State {
        return self.store.state
    }

    // MARK: - Recording

    func record(action: SIMAction) {
        self.recorded.append(action)
    }


    /// Replay actions up to timestamp
    func replay(upTo timestamp: TimeInterval) {
        let actions = self.recorded.filter {
            $0.timestamp <= timestamp
        }
        self.replay(actions: actions)
    }

    func replay(actions: [Action]) {
        actions.forEach { [weak self] in
            self?.store.dispatch($0)
        }
    }
}
