module Capucine
  class Incloudr
    require 'open-uri'
    require 'fileutils'
    require 'uglifier'
    require 'packr'

    def self.run_once
      files = Capucine.settings.config['incloudr_files']
      return if files.length == 0
      
      files.each do |base, files|
        self.pack base, files
      end
      puts "[js pack] - Packaged"
    end

    def self.pack base = nil, files = []
      s = Capucine.settings
      out = File.join s.working_dir, s.config['incloudr_output_dir']
      
      output_file = File.join out, base
      output_file_min = File.join out, base.gsub('.js', '.min.js')
      
      FileUtils.mkdir_p out if not File.exist?(out)
      
      content = ""
      # content_min = ""

      files.each do |js_file|
        extended = File.join s.working_dir, js_file
        content << File.read(extended) if File.exist?(extended)
      end
      
      f = File.open(output_file, 'w')
      f.write('')
      f.write(content)
      f.close

      # f2 = File.open(output_file_min, 'w')
      # f2.write('')
      # f2.write(content_min)
      # f2.close

    end

    # def self.lib_root
    #   return "http://dln.name/"
    # end

    # def self.compress file
    #   return if not File.exist?(file)
    #   file_name = file.gsub '.js', ''
    #   output_file = "#{file_name}.js"
    #   output_file_min = "#{file_name}.min.js"
    # end
    
    # def self.get_lib lib
    #   lib_name = lib[0]
    #   lib_version = lib[1]
    #   lib_url = "#{self.lib_root}#{lib_name}/#{lib_version}"
    #   lib_url_min = "#{lib_url}/min"
    #   lib_url_cdn = open(lib_url).read
    #   lib_url_cdn_min = open(lib_url_min).read
    #   lib_content = open(lib_url_cdn).read
    #   lib_content_min = open(lib_url_cdn_min).read
    #   total = [lib_content, lib_content_min]
    # end

  end
end
