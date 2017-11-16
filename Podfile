# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'summer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for summer.ios
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    #pod 'Alamofire', '~> 4.5.0'
    #pod 'AlamofireImage', '~> 3.3'
    pod 'Kingfisher'
    pod 'Atributika'
    pod 'Fabric', '~> 1.7.2'
    pod 'Crashlytics', '~> 3.9.3'
    pod 'PlayerKit'
    pod 'ModelMapper'
    pod 'Swinject', '~> 2.1.0'
    pod 'SwinjectStoryboard', '~> 1.0'
    
    target 'summerTests' do
        inherit! :search_paths
        #pod 'OCMock', '~> 2.0.1'
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts target.name
        if
            target.name == 'PlayerKit'
            
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
