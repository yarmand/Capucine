module Capucine
  class CompassSass
    def self.update_plugins force = false
      plugins = Capucine.settings.config['compass_plugins']
      return if not plugins

      plugins.each do |plugin|
        require 'rubygems'
        require 'sass'

        begin 
          require "#{plugin}"
        rescue LoadError
          system("gem install #{plugin} --no-ri --no-rdoc") if force
        end
      end
    end

    def self.update_config
      settings = Capucine.settings
      template_file = File.join settings.gem_content_dir, 'templates', 'compass_config.erb'
      output_file = File.join settings.working_dir, '.compass.rb'
      
      config_ = settings.config

      result = Capucine::Tools.render_template template_file, config_
      
      f = File.open(output_file, 'w')
      f.write(result)
      f.close
      
      # DEBUG HERE :
      # self.update_plugins force = true
    end
    
    # def self.load_my_functions
    #   rb_files = Dir.glob "#{Capucine.settings.working_dir}/#{Capucine.settings.config['compass_compass_files_dir']}/**/**.rb"
    #   
    #   rb_files.each do |file|
    #     require "#{file}"
    #   end
    #   
    # end

    def self.import_css
      s = Capucine.settings
      import_dir = File.join s.working_dir, s.config['compass_import_css_dir']
      output_dir= File.join s.working_dir, s.config['compass_import_output_dir']

      Dir.mkdir(import_dir) if not File.directory?(import_dir)
      Dir.mkdir(output_dir) if not File.directory?(output_dir)
      
      formats = s.config['compass_import_formats'].split
      from_format = formats[0]
      to_format = formats[2]
      
      command = "sass-convert -R --from #{from_format} --to #{to_format} #{import_dir} #{output_dir}"
      # SLOW HERE :
      system(command)
      Capucine::Tools.archive_file import_dir
      
    end

    def self.run_once
      self.update_config
      # self.load_my_functions
      self.import_css if Capucine.settings.config['compass_import_css']
      config = File.join Capucine.settings.working_dir, '.compass.rb'
      command = "compass compile --quiet --config #{config} #{Capucine.settings.working_dir}"
      # SLOW HERE :
      system(command)

      puts "[compass] - Compiled"
    end

    def self.proc_watch
      self.update_config

      config_file = File.join Capucine.settings.working_dir, '.compass.rb'

      command = "compass watch --config #{config_file} #{Capucine.settings.working_dir}"
      
      # SLOW HERE :
      compass_proc = Thread.new {
        system(command)
      }

      return compass_proc

    end

  end
  
end
