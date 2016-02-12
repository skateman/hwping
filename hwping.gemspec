$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'hwping/constants'

Gem::Specification.new do |s|
  s.name             = 'hwping'
  s.version          = HWPing::VERSION
  s.license          = 'GPL-2'
  s.summary          = 'Hardware Pinger'
  s.description      = 'IRC bot for HW pinging with the Dream Cheeky Thunder missile launcher'
  s.authors          = 'Dávid Halász'
  s.email            = 'skateman@skateman.eu'
  s.homepage         = HWPing::REPO_URL

  s.require_paths    = ['lib']

  s.executables      = 'hwping'

  s.files            = Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'libusb', '~> 0.5.0'
  s.add_dependency 'cinch', '~> 2.2.4'

  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.36.0'
end
