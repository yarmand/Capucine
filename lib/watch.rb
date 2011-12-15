module Capucine
  class Watchr
    require 'compass-sass.rb'
    require 'coffeescript.rb'
    require "templates.rb"

    def self.watch config_file
      self.compile
      Capucine.settings.get_config config_file
      @config = Capucine.settings.config
      
      compass_proc = Capucine::CompassSass.proc_watch if @config['compass_enable']
      coffeescript_proc = Capucine::Coffee.proc_watch if @config['coffeescript_enable']
      templates_proc = Capucine::Templates.proc_watch if @config['templates_enable']
      
      compass_proc.join if compass_proc
      coffeescript_proc.join if coffeescript_proc
      templates_proc.join if templates_proc
    end

    def self.compile config_file
      Capucine.settings.get_config config_file
      @config = Capucine.settings.config
      
      Capucine::CompassSass.run_once if @config['compass_enable']
      Capucine::Coffee.run_once if @config['coffeescript_enable']
      Capucine::Templates.run_once if @config['templates_enable']
    end
  end
end
