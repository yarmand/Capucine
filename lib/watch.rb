module Capucine
  class Watchr
    require 'compass-sass.rb'
    require 'coffeescript.rb'
    require 'incloudr.rb'
    require "templates.rb"

    def self.watch config_file = nil
      self.compile config_file

      if config_file
        Capucine.settings.get_config config_file
      else
        Capucine.settings.get_config
      end

      @config = Capucine.settings.config

      sass_proc = Capucine::CompassSass.proc_watch if @config['sass_enable']
      coffeescript_proc = Capucine::Coffee.proc_watch if @config['coffeescript_enable']
      templates_proc = Capucine::Templates.proc_watch if @config['templates_enable']

      sass_proc.join if sass_proc
      coffeescript_proc.join if coffeescript_proc
      templates_proc.join if templates_proc
    end

    def self.compile config_file = nil
      if config_file
        Capucine.settings.get_config config_file
      else
        Capucine.settings.get_config
      end

      @config = Capucine.settings.config

      Capucine::CompassSass.run_once if @config['sass_enable']
      Capucine::Coffee.run_once if @config['coffeescript_enable']
      Capucine::Templates.run_once if @config['templates_enable']
      Capucine::Incloudr.run_once if @config['incloudr_enable']
    end
  end
end
