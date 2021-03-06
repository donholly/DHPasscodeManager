Pod::Spec.new do |s|
  s.name         = "DHPasscodeManager"
  s.author       = "Don Holly"
  s.version      = "0.9.6"
  s.summary      = "The easiest way to add a passcode and TouchID support to your iOS App."
  s.license      = { :type => 'MIT', :text => <<-LICENSE
                      The MIT License (MIT)
                      Copyright (c) 2014
                      Permission is hereby granted, free of charge, to any person obtaining a copy
                      of this software and associated documentation files (the "Software"), to deal
                      in the Software without restriction, including without limitation the rights
                      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                      copies of the Software, and to permit persons to whom the Software is
                      furnished to do so, subject to the following conditions:
                      The above copyright notice and this permission notice shall be included in
                      all copies or substantial portions of the Software.
                      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                      THE SOFTWARE.
                      LICENSE
                  }
  s.homepage     = "https://www.github.com/donholly/DHPasscodeManager"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/donholly/DHPasscodeManager.git" }
  s.source_files = "DHPasscodeManager/**/*.{h,m}"

  s.dependency "SAMKeychain"
  s.dependency "ReactiveCocoa", "2.3.1"

  s.framework    = 'LocalAuthentication'

  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }

end
