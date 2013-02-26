spec = Gem::Specification.new do |s|
  s.name = "baya"
  s.version = "0.1.2"
  s.summary = "Simple backup and archive automation tool"
  s.author = "Vivien Barousse"
  s.email = "barousse.vivien@gmail.com"
  s.homepage = "http://github.com/VivienBarousse/baya"

  s.extra_rdoc_files = %w(README.rdoc)
  s.rdoc_options = %w(--main README.rdoc)

  s.files = %w(README.rdoc) + Dir.glob("{bin,lib}/**/*")
  s.require_paths = ["lib"]
  
  s.executables = Dir.glob("bin/**").map { |f| File.basename(f) }

  s.add_dependency "git", "1.2.5"
  s.add_dependency "curb", "0.8.3"
  s.add_dependency "yajl-ruby", "1.1.0"

  s.add_development_dependency "rspec", "2.13.0"
  s.add_development_dependency "simplecov", "0.7.1"
end
