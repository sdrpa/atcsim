/**
 Created by Sinisa Drpa on 2/12/17.

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
import Dispatch

/// Metronome provides steady beat, but it doesn't know the current time
final class Metronome {

    static let minimumSpeed = 1
    static let maximumSpeed = 30

    fileprivate var _timer: Timer?
    fileprivate var timer: Timer? {
        set {
            if let old = _timer {
                old.invalidate()
            }
            _timer = newValue
            self.runningChanged?(self.isRunning)
        }
        get {
            return _timer
        }
    }
    fileprivate var event: (() -> Void)?
    fileprivate var runningChanged: ((_ newValue: Bool) -> Void)?
    fileprivate var speedChanged: ((_ newValue: Int) -> Void)?

    var isRunning: Bool {
        return (self.timer != nil)
    }
    var _speed = 1
    var speed: Int {
        set {
            _speed = newValue.bound(min: Metronome.minimumSpeed, max: Metronome.maximumSpeed)
            if self.isRunning {
                self.timer = self.createTimer(interval: TimeInterval(_speed))
            }
            self.speedChanged?(_speed)
        }
        get {
            return _speed
        }
    }

    init(event: @escaping () -> Void,
         runningChanged: @escaping (_ newValue: Bool) -> Void,
         speedChanged: @escaping (_ newValue: Int) -> Void)
    {
        self.event = event
        self.runningChanged = runningChanged
        self.speedChanged = speedChanged
    }

    fileprivate func createTimer(interval: TimeInterval) -> Timer {
        let newInteval = 1/interval
        let timer: Timer
        if #available(OSX 10.12, *) {
            timer = Timer.scheduledTimer(withTimeInterval: newInteval, repeats: true) { [weak self] _ in
                self?.event?()
            }
        } else {
            fatalError()
        }
        return timer
    }

    func toggle() {
        if self.isRunning {
            self.pause()
        } else {
            self.start()
        }
    }

    func pause() {
        if !self.isRunning {
            return
        }
        self.timer = nil
    }

    func start() {
        if self.isRunning {
            return
        }
        self.timer = self.createTimer(interval: TimeInterval(self.speed))
    }
}
