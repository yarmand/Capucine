module Capucine
  class Incloudr
    require 'open-uri'
    require 'fileutils'
    require 'json'
    require 'packr'

    @@noderoot = 'http://registry.npmjs.org/'
    @@cdnjsroot = 'https://raw.github.com/cdnjs/cdnjs/master/ajax/libs/'
    @@cdnjs = 'http://www.cdnjs.com/packages.json'

    def self.run_once
      files = Capucine.settings.config['incloudr_libs']
      return false if files.length == 0
      dir = File.join(Capucine.settings.working_dir, Capucine.settings.config['incloudr_output_dir'])
      FileUtils.rm_r dir if File.exist?(dir)
      FileUtils.mkdir_p dir

      @file = nil
      files.each {|file| self.pack file}
      puts "[incloudr] - Packaged"
    end

    def self.pack file
      @file = file

      if @file.kind_of? String # CDNJS
        @file = {}
        @file['name'] = file
        @file['type'] = 'cdnjs'
      else
        @file['type'] = 'npm' unless @file['source'] # NPM
      end

      @file['type'] = @file['type'] || 'url' # URL

      @output = File.join(Capucine.settings.working_dir, Capucine.settings.config['incloudr_output_dir'], @file['name'].gsub(/$/, '.js'))
      @output_min = File.join(Capucine.settings.working_dir, Capucine.settings.config['incloudr_output_dir'], @file['name'].gsub(/$/, '.min.js'))

      self.cdnjs if @file['type'] == 'cdnjs'
      self.url if @file['type'] == 'url'
      # self.npm(file) if type == 'npm'
    end


    def self.url raw_content = nil
      content = raw_content || open(@file['source']).read
      content_min = ""
      content_min << Packr.pack(content)

      f1 = File.open(@output, 'w+')
      f1.write(content)
      f1.close

      f2 = File.open(@output_min, 'w+')
      f2.write(content_min)
      f2.close
    end


    def self.cdnjs
      cdnjs_url_pkg = "#{@@cdnjsroot}#{@file['name']}/package.json"
      content = JSON.parse open(cdnjs_url_pkg).read
      version = @file['version'] || content['version']
      filename = content['filename']
      raw_file_url = "#{@@cdnjsroot}#{@file['name']}/#{version}/#{filename}"
      raw_content = open(raw_file_url).read
      self.url raw_content
    end

    def self.npm file
      # infos = JSON.parse open("#{@@noderoot}#{file['name']}").read
      # version = file['version'] || infos['dist-tags']['lastest']
      # lib = infos['versions'][version]
      # tarball_url = lib['dist']['tarball']

      # tarball = open(tarball_url).read

      # p version

    end

    def self.list
      content = JSON.parse open(@@cdnjs).read
      packages = content['packages']
      packages.each {|p| puts "#{p['name']}\n"}
    end

  end
end
