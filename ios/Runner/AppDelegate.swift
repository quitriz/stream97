import UIKit
import Flutter
import flutter_downloader
import AVFoundation
import AVKit
import fl_pip

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    var url = ""
    var navigationController = UINavigationController()
    var overlayPlayerView: UIView?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)
        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
        print("Enter in iOS")

        // Safely unwrap the rootViewController and cast its type.
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not of type FlutterViewController")
        }
        
        let webviewChannel = FlutterMethodChannel(name: "webviewChannel", binaryMessenger: controller.binaryMessenger)

        navigationController = UINavigationController(rootViewController: controller)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        webviewChannel.setMethodCallHandler({ [self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "webview") {
                var dic = NSDictionary()
                dic = call.arguments as! NSDictionary
                print("URL", dic["url"] ?? "")

                let vc = WKWViewController(nibName: "WKWViewController", bundle: nil)
                vc.dic = dic as! NSMutableDictionary
                navigationController.pushViewController(vc, animated: false)

                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            } else {
                result("")
            }
        })

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Function to play video with custom PiP-like behavior (20% height, 70% width)
    func playVideoWithCustomPiP(urlString: String) {
        guard let videoURL = URL(string: urlString) else { return }

        // Create an AVPlayer for the video
        let player = AVPlayer(url: videoURL)

        // Create an AVPlayerLayer to display the video
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill

        // Calculate dimensions for the custom PiP-like overlay
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pipWidth = screenWidth * 0.7 // 70% of the screen width
        let pipHeight = screenHeight * 0.2 // 20% of the screen height

        // Create a custom overlay view for the player
        let pipView = UIView(frame: CGRect(x: screenWidth - pipWidth - 16, // Positioned with 16px margin from the right
                                           y: screenHeight - pipHeight - 16, // Positioned with 16px margin from the bottom
                                           width: pipWidth,
                                           height: pipHeight))
        pipView.backgroundColor = .black
        pipView.layer.cornerRadius = 10
        pipView.layer.masksToBounds = true

        // Add player layer to the custom view
        playerLayer.frame = pipView.bounds
        pipView.layer.addSublayer(playerLayer)

        // Add the custom PiP-like view to the main window
        if let window = UIApplication.shared.windows.first {
            window.addSubview(pipView)
            overlayPlayerView = pipView
        }

        // Play the video
        player.play()

        // Optional: Add a close button to dismiss the PiP overlay
        let closeButton = UIButton(frame: CGRect(x: pipWidth - 30, y: 10, width: 20, height: 20))
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .red
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(closePiPOverlay), for: .touchUpInside)
        pipView.addSubview(closeButton)
    }

    @objc private func closePiPOverlay() {
        overlayPlayerView?.removeFromSuperview()
        overlayPlayerView = nil
    }

    func SwitchViewController() {
        // Safely unwrap the rootViewController and cast its type.
        guard let controller = window?.rootViewController as? FlutterViewController else {
            print("Error: Could not get FlutterViewController to switch.")
            return
        }
        let navigationController = UINavigationController(rootViewController: controller)
        // Use optional chaining (?) to safely access properties on the optional 'window'.
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
