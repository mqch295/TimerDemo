//
//  TimerViewModel.swift
//  TimerDemo
//
//  Created by Mqch on 2021/4/15.
//

import Foundation
import ReactorKit
class TimerViewModel: Reactor {
    enum UIStyle {
        case running
        case pause
    }
    enum Action {
        case startOrPause
        case recordOrReset
    }
    enum Mutation {
        case running
        case pause
        case record
        case reset
    }
    let initialState: State = State(uiStyle: .pause, time: "00:00.00", recordTimes: [])
    struct State {
        var uiStyle: UIStyle
        var time: String
        var recordTimes: [String]
    }
    private var isPause: Bool = true
    private var currentNum: Int = 0
    private var isInitTimer: Bool = false
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startOrPause:
            isPause.toggle()
            if isPause{
                return .just(.pause)
            }else{
                guard !isInitTimer else { return .empty() }
                isInitTimer = true
                return Observable<Int>.interval(.milliseconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
                    .filter{ [weak self] _ in !(self?.isPause ?? true) }
                    .flatMap { [weak self] _ -> Observable<Mutation> in
                        self?.currentNum += 1
                        return .just(.running)
                    }
            }
        case .recordOrReset:
            return .just(isPause ? .reset : .record)
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .running:
            state.uiStyle = .running
            state.time = numToTimeStr()
        case .pause:
            state.uiStyle = .pause
        case .record:
            print(numToTimeStr())
            state.recordTimes.insert(numToTimeStr(), at: 0)
        case .reset:
            currentNum = 0
            state.time = numToTimeStr()
            state.recordTimes = []
        }
        return state
    }
    private func numToTimeStr() -> String{
        guard self.currentNum != 0 else { return "00:00.00"}
        let minutes = self.currentNum / 60000
        let seconds = self.currentNum % 60000 / 1000
        let msec = self.currentNum % 1000 / 10
        return "\(minutes < 10 ? "0\(minutes)" : "\(minutes)"):\(seconds < 10 ? "0\(seconds)" : "\(seconds)").\(msec < 10 ? "0\(msec)" : "\(msec)")"
    }
}
