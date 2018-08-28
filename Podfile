# Uncomment the next line to define a global platform for your project
# platform :ios, '8.0'

use_frameworks!

inhibit_all_warnings!

def shared_pods
    pod 'VimeoNetworking', :git => 'git@github.com:vimeo/VimeoNetworking.git', :branch => 'develop'
    pod 'VimeoUpload', :git => 'git@github.com:vimeo/VimeoUpload.git', :branch => 'develop'
    pod 'PlayerKit'
    pod 'PromiseKit', '~> 6.0'
end

target 'BlueView' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        
        # Build the following framework with Swift 3.3.
        if target.name == 'VimeoUpload'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.3'
            end
        end
    end
end