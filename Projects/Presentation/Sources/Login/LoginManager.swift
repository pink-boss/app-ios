//
//  LoginManager.swift
//  Presentation
//
//  Created by Hohyeon Moon on 2023/05/12.
//

import Foundation
import UIKit

import AuthenticationServices
import GoogleSignIn
import RxMoya
import RxSwift

import Networking

// MARK: - SocialLogin

public enum SocialLogin {
  case google
  case apple
}

// MARK: - LoginManager

final class LoginManager {
  private let disposeBag = DisposeBag()

  weak var loginViewController: LoginViewController?
  var loginSingleEvent: ((SingleEvent<String>) -> Void)?

  func login(with social: SocialLogin) -> Single<String> {
    switch social {
    case .apple:
      return appleLogin()
    case .google:
      return googleLogin()
    }
  }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension LoginManager {
  private func googleLogin() -> Single<String> {
    guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
      return .error(NSError(domain: "rootViewController", code: 0))
    }

    return .create { single -> Disposable in

      GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
        if let error {
          single(.failure(error))
        }

        if let accessToken = result?.user.accessToken {
          single(.success(accessToken.tokenString))
        }
      }

      return Disposables.create()
    }
  }

  private func appleLogin() -> Single<String>  {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])

    authorizationController.delegate = loginViewController
    authorizationController.presentationContextProvider = loginViewController
    authorizationController.performRequests()

    return .create { [weak self] single in
      self?.loginSingleEvent = single

      return Disposables.create {
        authorizationController.delegate = nil
        authorizationController.presentationContextProvider = nil
      }
    }
  }
}

extension LoginManager {
  func validateAppleIdCredential(_ credential: ASAuthorizationAppleIDCredential) {
    guard let tokenData = credential.authorizationCode,
          let token = String(data: tokenData, encoding: .utf8),
          let identityToken = credential.identityToken,
          let identity = String(data: identityToken, encoding: .utf8) else { return }

    loginSingleEvent?(.success(identity))

    provider.rx.request(.validateAppleUser(token: token, identity: identity))
      .subscribe { result in
        switch result {
        case .success:
          // response -> token
          print("hi")
        case .failure:
          // error handle
          print("hi")
        }
      }
      .disposed(by: disposeBag)
  }

  func handlePasswordCredential(_ credential: ASPasswordCredential) {
    _ = credential.user
    _ = credential.password
  }
}
