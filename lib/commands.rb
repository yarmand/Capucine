module Capucine
  class Commands

    require 'tools.rb'
    require 'watch.rb'

    def initialize args
      first_arg = args[0]
      second_arg = args[1]
      cap = Capucine.new

      if first_arg == 'help' or first_arg == 'h'
        Capucine::Commands.help
      elsif first_arg == 'new' or first_arg == 'n'
        Capucine::Tools.new_project second_arg
      elsif first_arg == 'init' or first_arg == 'i'
        Capucine::Tools.init second_arg
      elsif first_arg == 'compile' or first_arg == 'c'
        Capucine::Watchr.compile second_arg
      elsif first_arg == 'watch' or first_arg == 'w'
        Capucine::Watchr.watch second_arg
      elsif first_arg == 'clean'
        Capucine::Tools.clean
      elsif first_arg == 'update' or first_arg == 'u'
        system('gem install capucine')
      else
        Capucine::Commands.help
      end
    end

    def self.help
      file_name = File.join Capucine.settings.gem_content_dir, 'templates', 'cmd_help.erb'
      version = File.read(File.join(Capucine.settings.gem_dir, 'VERSION'))
      render = Capucine::Tools.render_template file_name, version
      puts render
      exit
    end

  end
end

