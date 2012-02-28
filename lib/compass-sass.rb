module Capucine
  class CompassSass

    def self.update_plugins gems
      return if not gems
      gems.each do |plugin|
        begin
          require "#{plugin}"
        rescue LoadError
          system("gem install #{plugin} --no-ri --no-rdoc")
        end
      end
    end

    def self.update_config
      settings = Capucine.settings
      template_file = File.join settings.gem_content_dir, 'templates', 'compass_config.erb'
      output_file = File.join settings.working_dir, '.compass.rb'

      settings.config['compass_plugins_list'] = []
      plugins_gems = []

      plugins = settings.config['compass_plugins']

      if plugins.size > 0
        plugins.each do |key, value|
          settings.config['compass_plugins_list'].push key

          if value and value.length > 0
            plugins_gems.push value
          else
            plugins_gems.push key
          end

        end
      end
      config_ = settings.config
      result = Capucine::Tools.render_template template_file, config_

      f = File.open(output_file, 'w')
      f.write(result)
      f.close

      self.update_plugins plugins_gems
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
      import_dir = File.join s.working_dir, s.config['sass_import_css_dir']
      output_dir= File.join s.working_dir, s.config['sass_import_output_dir']

      Dir.mkdir(import_dir) if not File.directory?(import_dir)
      Dir.mkdir(output_dir) if not File.directory?(output_dir)

      formats = s.config['sass_import_formats'].split
      from_format = formats[0]
      to_format = formats[2]

      command = "sass-convert -R --from #{from_format} --to #{to_format} #{import_dir} #{output_dir}"
      system(command)
      Capucine::Tools.archive_file import_dir

    end

    def self.run_once
      self.update_config
      # self.load_my_functions
      self.import_css if Capucine.settings.config['sass_import_css']
      config = File.join Capucine.settings.working_dir, '.compass.rb'
      command = "compass compile --quiet --config #{config} #{Capucine.settings.working_dir}"
      system(command)
      puts "[compass] - Compiled"
    end

    def self.export_path
      require 'compass'
      require 'rubygems'
      path_compass = Gem.loaded_specs['compass'].full_gem_path
      ENV['PATH'] = "#{path_compass}:#{Capucine.settings.gem_dir}:#{ENV['PATH']}"
    end

    def self.proc_watch
      self.update_config
      config_file = File.join Capucine.settings.working_dir, '.compass.rb'
      compass_args = ['watch', '--config', config_file, Capucine.settings.working_dir]
      proc_watch = Thread.new {
        self.exec_compass compass_args
      }
      return proc_watch
    end

    def self.exec_compass compass_args
      require 'compass'
      require 'compass/exec'
      Compass::Exec::SubCommandUI.new(compass_args).run!
    end

  end

end
