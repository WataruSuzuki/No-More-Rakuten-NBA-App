//
//  Store.swift
//  PomodoroHub
//
//  Created by 鈴木 航 on 2021/02/24.
//

import Foundation
import Combine

protocol Action {
    associatedtype Mutation
    func mapToMutation(dependencies: Dependencies) -> AnyPublisher<Mutation, Never>
}

typealias Reducer<State, Mutation> = (inout State, Mutation) -> Void

final class Store<AppState, AppAction: Action>: ObservableObject {
    @Published private(set) var state: AppState
    
    private let appReducer: Reducer<AppState, AppAction.Mutation>
    private let dependencies: Dependencies
    private var cancellables: Set<AnyCancellable> = []

    init(
        initialState: AppState,
        appReducer: @escaping Reducer<AppState, AppAction.Mutation>,
        dependencies: Dependencies
    ) {
        self.state = initialState
        self.appReducer = appReducer
        self.dependencies = dependencies
    }

    func dispatch(_ action: AppAction) {
        action
            .mapToMutation(dependencies: self.dependencies)
            .receive(on: DispatchQueue.main)
            .sink { self.appReducer(&self.state, $0) }
            .store(in: &cancellables)
    }
}
