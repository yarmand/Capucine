module Capucine

  class NoUserConfigFile < RuntimeError
  end

  class Settings
    require 'rubygems'
    require 'yaml'

    attr_accessor :current_dir, :project_name, :is_usable, :config, :gem_dir, :gem_content_dir, :working_dir, :external_config, :user_config_file
    def initialize
      @current_dir = File.expand_path Dir.pwd
      @project_name = 'capucine'
      @is_usable = false
      @external_config = false
      @config = nil
      @gem_dir = Gem.loaded_specs[@project_name].full_gem_path
      @gem_content_dir = File.join @gem_dir, 'content'

      self.reset_working_dir
    end

    def get_config user_config_file = nil
      @user_config_file = user_config_file
      default = File.join @gem_content_dir, "templates", "#{@project_name}.yaml"
      @config = YAML::load(File.open(default))

      if user_config_file
        from_user = File.expand_path user_config_file
        @external_config = true
        @working_dir = File.dirname from_user
      else
        from_user = File.join @working_dir, "#{@project_name}.yaml"
      end

      raise NoUserConfigFile, caller if not File.exist? from_user

      @is_usable = true
      additional = YAML::load(File.open(from_user))

      if additional
        additional.each do |k, v|
          @config[k] = v
        end
      end
      #self.test_config
    end

    # def test_config
    #   conf_dirs = []
    #   dirs = []
    #   for conf in conf_dirs
    #     conf = @config[conf]
    #     dirs.push File.join(@working_dir,conf)
    #   end

    #   for dir in dirs
    #     unless File.directory?(dir)
    #       puts "[error] #{dir} - Does not exist."
    #       exit
    #     end
    #   end
    # end

    def reset_working_dir
      if @external_config
        from_user = File.expand_path @user_config_file
        @working_dir = File.dirname from_user
      else
        @working_dir = File.expand_path Dir.pwd
      end
    end
  end
end

