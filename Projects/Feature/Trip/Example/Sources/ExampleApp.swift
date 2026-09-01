import SwiftUI
import UIKit

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      ExampleScene()
        .ignoresSafeArea()
    }
  }
}

private struct ExampleScene: UIViewControllerRepresentable {
  func makeCoordinator() -> AppFlowCoordinator {
    AppFlowCoordinator(
      dependencies: AppComponent(),
      navigationController: UINavigationController()
    )
  }

  func makeUIViewController(
    context: Context
  ) -> UIViewController {
    context.coordinator.start()
    return context.coordinator.navigationController
  }

  func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
