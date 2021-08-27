platform :ios, '14.0'

target 'SneakersnShit' do
  use_frameworks!

  inhibit_all_warnings!

  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Functions'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'GoogleSignIn'
  pod 'Firebase/Storage'
  # pod 'FBSDKLoginKit'
  pod 'OasisJSBridge'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end



