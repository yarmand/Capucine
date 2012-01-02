# -*- ruby -*-
# require 'psych'
# subjs, revojs, jeanjs, wingjs,  

require 'rubygems'
require 'rubygems/package_task'
require 'rubygems/installer'
require 'fileutils'

PKG_FILES = FileList[
  "VERSION",
  "content/**/**",
  "lib/**/**",
  "bin/*",
]

packages_location = "pkg"

$spec = Gem::Specification.new do |s|
  s.name = 'capucine'
  s.description = "Capucine, the missing tool for frontend developers."
  s.summary = "."
  
  s.version = File.read('VERSION')
  s.date = "#{Time.now.strftime("%Y-%m-%d")}"
  s.platform    = Gem::Platform::RUBY
  
  s.author = "Damian Le Nouaille"
  s.homepage = "http://capucine.dln.name"
  s.email = "dam@dln.name"
  
  s.files = PKG_FILES.to_a
  
  s.require_path = "lib"
  s.bindir = "bin"
  s.executables = ["#{s.name}"]
  s.default_executable = "#{s.name}"
  
  # s.add_dependency('rb-fsevent')
  s.add_dependency('fssm')
  s.add_dependency('compass')
  s.add_dependency('coffee-script')
  s.add_dependency('uglifier')
  s.add_dependency('packr')
  s.add_dependency('term-ansicolor')
  s.add_dependency('zip')
  s.add_dependency('sass-capucine')
end

# ====================================================
# ====================================================
Gem::PackageTask.new($spec) do |pkg|
  # pkg.need_zip = true
  # pkg.need_tar = t}"e
end

packages_name = "#{packages_location}/#{$spec.name}-#{$spec.version}.gem"

namespace 'gem' do
  task :install do
    system("gem uninstall -a -q -x #{$spec.default_executable}")
    FileUtils.rm_rf "#{packages_location}/*"
    Gem::Installer.new(packages_name).install
    puts "#{$spec.default_executable} Installed."
  end
end

task :watch do
  require 'fssm'
  system('rake')
  FSSM.monitor(Dir.pwd) do
    
    def make_gem b, r
      exclude = ['pkg/']
      exclude.each do |dir|
        if not r.match(/^#{dir}/)
          system('rake')
        end
      end
    end

    update do |b, r|
      make_gem b, r
    end

    create do |b, r|
      make_gem b, r
    end

    delete do |b, r|
      make_gem b, r
    end
  end

end


task :default => [:package, 'gem:install']
