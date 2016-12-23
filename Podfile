platform :ios, '9.0'
use_frameworks!

target 'SkillCloud' do

pod 'AlamofireSwiftyJSON'
pod 'AMKSlidingTableViewCell'
pod 'ASIACheckmarkView'
pod 'PromiseKit'
pod 'PromiseKit/AssetsLibrary'
pod 'PromiseKit/MessageUI'
pod 'RSKImageCropper'
pod 'MRProgress'
pod 'CocoaLumberjack'
pod 'DRNSnackBar'

end

post_install do |installer|
    filename = 'Pods/PromiseKit/Categories/Foundation/NSNotificationCenter+Promise.swift'
    contents = '// This file removed due to Swift compiler bug https://bugs.swift.org/browse/SR-1427\n'\
               '// PromiseKit tracking of this issue: https://github.com/mxcl/PromiseKit/issues/415\n'
    system("chmod +w #{filename}; printf \"#{contents}\" > #{filename}; chmod -w #{filename}")
end
