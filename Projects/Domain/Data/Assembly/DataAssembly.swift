//
//  DataAssembly.swift
//  Data
//
//  Created by 박천송 on 2023/04/27.
//

import Foundation

import Swinject

import Domain

// MARK: - DataAssembly

public final class DataAssembly: Assembly {
  public init() {}

  public func assemble(container: Container) {
    let registerFunctions: [(Container) -> Void] = [
      registerGuideRepository
    ]

    registerFunctions.forEach { $0(container) }
  }

  private func registerGuideRepository(container: Container) {
    container.register(GuideRepository.self) { _ in
      GuideRepositoryImpl()
    }
  }
}

// MARK: - Resolver

private extension Resolver {
  func resolve<Service>() -> Service! {
    resolve(Service.self)
  }
}
