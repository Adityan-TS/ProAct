import Flutter
import UIKit

@objc public class UsageStatsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "usage_stats", binaryMessenger: registrar.messenger())
        let instance = UsageStatsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "checkUsagePermission":
            // iOS doesn't have direct equivalent to Android's PACKAGE_USAGE_STATS permission
            // Return true to avoid breaking the app, but actual functionality is limited
            result(true)
            
        case "grantUsagePermission":
            // On iOS, we can't directly open usage settings, so we'll open the app's settings page
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            result(nil)
            
        case "queryUsageStats", "queryEvents", "queryEventStats", "queryConfiguration", "queryAndAggregateUsageStats":
            // iOS doesn't provide direct access to app usage statistics like Android
            // Return empty list to avoid breaking the app
            result([])
            
        case "queryNetworkUsageStats":
            // iOS doesn't provide direct access to network usage statistics like Android
            // Return empty list to avoid breaking the app
            result([])
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}