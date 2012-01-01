module Capucine
  
  class NoUserConfigFile < RuntimeError
  end

  class Settings
    require 'rubygems'
    require 'yaml'
    
    attr_accessor :current_dir, :project_name, :is_usable, :config, :gem_dir, :gem_content_dir, :working_dir
    
    def initialize
      @current_dir = File.expand_path Dir.pwd
      @project_name = Capucine.get_name
      @is_usable = false
      @config = nil
      @gem_dir = Gem.loaded_specs[Capucine.get_name].full_gem_path
      @gem_content_dir = File.join @gem_dir, 'content'

      self.reset_working_dir
    end

    
    def get_config user_config_file = nil
      default = File.join @gem_content_dir, "templates", "#{Capucine.get_name}.yaml"
      @config = YAML::load(File.open(default)) 

      from_user = File.join @working_dir, "#{Capucine.get_name}.yaml"
      from_user = File.expand_path user_config_file if user_config_file
      
      raise NoUserConfigFile, caller if not File.exist? from_user
      
      @is_usable = true
      additional = YAML::load(File.open(from_user))

      if additional
        additional.each do |k, v|
          @config[k] = nil
          @config[k] = v
        end
      end
      #self.test_config
    end  

    def test_config
      # TO DO :
      conf_dirs = [] 
      dirs = []
      for conf in conf_dirs
        conf = @config[conf]
        dirs.push File.join(@working_dir,conf)
      end
      
      for dir in dirs
        unless File.directory?(dir)
          puts "[error] #{dir} - Does not exist."
          exit
        end
      end
    end 

    def reset_working_dir
      @working_dir = File.expand_path Dir.pwd
    end
  end
end

