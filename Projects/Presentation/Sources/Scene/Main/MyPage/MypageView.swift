//
//  MyPageView.swift
//  Presentation
//
//  Created by 박천송 on 2023/05/19.
//

import UIKit

import FlexLayout
import PinLayout
import SnapKit
import Then

final class MyPageView: UIView {
  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .gray1
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()
  }
}