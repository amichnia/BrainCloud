# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, :deployment_target => '9.0'
inhibit_all_warnings!
use_frameworks!

def promises
    pod 'PromiseKit'
    pod 'PromiseKit/AssetsLibrary'
    pod 'PromiseKit/MessageUI'
end

def networking
    pod 'AlamofireSwiftyJSON'
end

def ui_components
    pod 'MRProgress'
    pod 'DRNSnackBar'
    pod 'LTMorphingLabel'
end

def assets_management
    pod 'R.swift'
end

def image_adjustment
    pod 'RSKImageCropper'
end

def logging
    pod 'CocoaLumberjack'
end


target 'SkillCloud' do
    promises
    networking
    ui_components
    image_adjustment
    assets_management
    logging
end
