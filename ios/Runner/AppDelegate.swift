import Flutter
import UIKit
// import NidThirdPartyLogin  // 임시 비활성화 - 크래시 원인 확인용

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 네이버 로그인 URL 콜백 처리 - 임시 비활성화
  // override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  //   if NidOAuth.shared.handleURL(url) {
  //     return true
  //   }
  //   return super.application(app, open: url, options: options)
  // }
}
