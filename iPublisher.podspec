
Pod::Spec.new do |s|

  s.name         = "iPublisher"
  s.version      = "1.6.0"
  s.summary      = "A publishing library for WebMarketer"
  s.description  = "A publishing library for WebMarketer on all iOS devices."
  s.homepage     = "https://www.webmarketer.ir/"

  s.license      = "MIT"

  s.author       = { "" => "" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/webmarketer/iPublisher.git", :tag => "1.6.0" }

  s.source_files  = "iPublisher", "iPublisher/**/*.{h,m,swift}"

  s.resources = "iPublisher/*.{ttf,xib,png,xcassets}"
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end
