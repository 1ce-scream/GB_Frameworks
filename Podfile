# Uncomment the next line to define a global platform for your project
platform :ios, '15.2'

target 'GB_Frameworks' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GB_Frameworks
  pod 'GoogleMaps'
  pod 'RealmSwift', '10.26.0'
  pod 'RxSwift'
  pod 'RxCocoa'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
 end
end