//
//  MypageBuildable.swift
//  Presentation
//
//  Created by 박천송 on 2023/05/19.
//

import Foundation
import UIKit

import Domain

// MARK: - MypageBuildable

public protocol MypageBuildable {
  func build(payload: MyPagePayload) -> UIViewController
}

// MARK: - MypagePayload

public struct MyPagePayload {
  public init() {}
}
