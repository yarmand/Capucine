# -*- encoding: utf-8 -*-

module Capucine

  class Tools
    require 'fileutils'
    require 'erb'
    require "compass-sass.rb"
    require "coffeescript.rb"
    require "incloudr.rb"

    def self.new_project name = nil

      if name
        new_project_name = name
      else
        new_project_name = Capucine.settings.project_name
      end

      Capucine.settings.working_dir = File.join Capucine.settings.current_dir, new_project_name

      self.archive_file Capucine.settings.working_dir
      FileUtils.mkdir Capucine.settings.working_dir if not File.directory? Capucine.settings.working_dir

      self.init files = true
    end

    def self.init all = nil
      self.archive_file File.join Capucine.settings.working_dir, 'capucine.yaml'

      if all
        files = Dir.glob File.join(Capucine.settings.gem_content_dir, 'shared', '**')
        self.archive_file Capucine.settings.working_dir
        FileUtils.cp_r files, Capucine.settings.working_dir
      end

      Capucine::Watchr.compile if all
      Capucine.settings.reset_working_dir
    end

    def self.render_template template_file, content = nil
      config = content
      template = ERB.new File.new(template_file).read
      output = template.result(binding)
    end

    def self.archive_file path, force = true
      return if not File.exist? path

      is_empty = false
      is_dir = File.directory? path
      dir_length = Dir.glob("#{path}/**").length if is_dir
      is_empty = true if dir_length == 0

      return if is_empty

      date = Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")
      new_dir_name = path

      if is_dir
        new_dir_name = "#{path}_#{date}"
      end

      if not is_dir
        extension = File.extname path
        base_path = File.dirname path
        file_name = File.basename(path, extension)
        new_dir_name = File.join base_path, "#{file_name}_#{date}#{extension}"
      end

      FileUtils.mkdir_p new_dir_name if is_dir
      FileUtils.mv path, new_dir_name

    end

    def self.clean
      FileUtils.rm File.join(Capucine.settings.working_dir, '.compass.rb')
      FileUtils.rm_r File.join(Capucine.settings.working_dir, '.incloudr')
    end

  end
end

