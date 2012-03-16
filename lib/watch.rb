module Capucine
  class Watchr
    require 'compass-sass.rb'
    require 'coffeescript.rb'
    require 'incloudr.rb'

    def self.watch config_file = nil
      self.compile config_file

      if config_file
        Capucine.settings.get_config config_file
      else
        Capucine.settings.get_config
      end

      @config = Capucine.settings.config

      sass_proc = Capucine::CompassSass.proc_watch if @config['sass']
      coffeescript_proc = Capucine::Coffee.proc_watch if @config['coffeescript']

      sass_proc.join if sass_proc
      coffeescript_proc.join if coffeescript_proc
    end

    def self.compile config_file = nil
      if config_file
        Capucine.settings.get_config config_file
      else
        Capucine.settings.get_config
      end

      @config = Capucine.settings.config

      Capucine::CompassSass.run_once if @config['sass']
      Capucine::Coffee.run_once if @config['coffeescript']
      Capucine::Incloudr.run_once if @config['incloudr']
    end
  end
end
