import UIKit

import PanModal
import ReactorKit
import RxSwift
import Toaster

import DesignSystem
import PBAnalyticsInterface
import PresentationInterface

// MARK: - SignUpViewController

final class SignUpViewController: UIViewController, StoryboardView {

  // MARK: UI

  private lazy var contentView = SignUpView()

  // MARK: Properties

  private var transition: UIViewControllerAnimatedTransitioning?

  private let mainTabBuilder: MainTabBarBuildable
  private let signUpSuccessBuilder: SingUpSuccessBuildable
  private let onboardingBuilder: OnboardingBuildable

  private let analytics: PBAnalytics

  var disposeBag = DisposeBag()

  // MARK: Initializing

  init(
    reactor: SignUpViewReactor,
    analytics: PBAnalytics,
    mainTabBuilder: MainTabBarBuildable,
    signUpSuccessBuilder: SingUpSuccessBuildable,
    onboardingBuilder: OnboardingBuildable
  ) {
    defer { self.reactor = reactor }
    self.analytics = analytics
    self.mainTabBuilder = mainTabBuilder
    self.signUpSuccessBuilder = signUpSuccessBuilder
    self.onboardingBuilder = onboardingBuilder
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func loadView() {
    view = contentView

    contentView.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)

    navigationController?.isNavigationBarHidden = false

    configureNavigationBar()
  }

  // MARK: Binding

  func bind(reactor: SignUpViewReactor) {
    bindButtons(with: reactor)
    bindContents(with: reactor)
    bindRoute(with: reactor)
  }

  private func bindButtons(with reactor: SignUpViewReactor) {
    contentView.genderView.manButton.rx.controlEvent(.touchUpInside)
      .map { Reactor.Action.genderButtonTapped("m") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    contentView.genderView.womanButton.rx.controlEvent(.touchUpInside)
      .map { Reactor.Action.genderButtonTapped("w") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    contentView.genderView.etcButton.rx.controlEvent(.touchUpInside)
      .map { Reactor.Action.genderButtonTapped("etc") }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    reactor.state.map(\.isCompleteButtonisEnabled)
      .distinctUntilChanged()
      .asObservable()
      .bind(to: contentView.completeButton.rx.isEnabled)
      .disposed(by: disposeBag)

    contentView.completeButton.rx.controlEvent(.touchUpInside)
      .map { Reactor.Action.completeButtonTapped }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindContents(with reactor: SignUpViewReactor) {
    reactor.state.compactMap(\.gender)
      .distinctUntilChanged()
      .asObservable()
      .subscribe(with: self) { `self`, gender in
        let selectedButton: String
        switch gender {
        case "m":
          selectedButton = "남자"
        case "w":
          selectedButton = "여자"
        case "etc":
          selectedButton = "기타"
        default:
          selectedButton = ""
        }
        self.contentView.genderView.configureButtons(selectedButton: selectedButton)
      }
      .disposed(by: disposeBag)
  }

  private func bindError(with reactor: SignUpViewReactor) {
    reactor.pulse(\.$error)
      .compactMap { $0 }
      .subscribe(with: self) { `self`, error in
        PBToast(content: error.localizedDescription)
          .show()
      }
      .disposed(by: disposeBag)
  }

  private func bindRoute(with reactor: SignUpViewReactor) {
    reactor.state.map(\.isSucceed)
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(with: self) { `self`, _ in
        let onboarding = self.onboardingBuilder.build(payload: .init())

        self.navigationController?.pushViewController(onboarding, animated: true)
      }
      .disposed(by: disposeBag)
  }


  // MARK: NavigationBar

  private func configureNavigationBar() {
    let backButton = UIBarButtonItem(
      image: DesignSystemAsset.iconChevronLeftLarge.image.withTintColor(.staticBlack),
      style: .plain,
      target: self,
      action: #selector(pop)
    )

    let passButton = UIBarButtonItem(
      title: "건너뛰기",
      style: .plain,
      target: self,
      action: #selector(passButtonTapped)
    )

    navigationItem.leftBarButtonItem = backButton
    navigationItem.leftBarButtonItem?.tintColor = .staticBlack
    navigationItem.title = "회원가입"
    navigationItem.rightBarButtonItem = passButton
    navigationItem.rightBarButtonItem?.tintColor = .gray700
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([
      NSAttributedString.Key.font: UIFont.captionRegular,
    ], for: .normal)
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([
      NSAttributedString.Key.font: UIFont.captionRegular,
    ], for: .highlighted)

    let attributes = [
      NSAttributedString.Key.foregroundColor: UIColor.staticBlack,
      NSAttributedString.Key.font: UIFont.defaultRegular,
    ]
    navigationController?.navigationBar.titleTextAttributes = attributes
  }

  @objc
  private func pop() {
    analytics.log(type: SignUpEvent.click(component: .back))
    navigationController?.popViewController(animated: true)
  }

  @objc
  private func passButtonTapped() {
    reactor?.action.onNext(.passButtonTapped)
  }
}

// MARK: UINavigationControllerDelegate

extension SignUpViewController: UINavigationControllerDelegate {
  func navigationController(
    _ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition
  }
}


// MARK: SignUpViewDelegate

extension SignUpViewController: SignUpViewDelegate {
  func inputFieldDidSelectYear(year: Int) {
    reactor?.action.onNext(.selectYear(year))
  }
}
