module Capucine
  class Commands

    require 'watch'

    def initialize args
      first_arg = args[0]
      second_arg = args[1]
      cap = Capucine.new

      if first_arg == 'help'
        Capucine::Commands.help
      elsif first_arg == 'new' or first_arg == 'n'
        Capucine::Tools.new_project second_arg
      
      elsif first_arg == 'init' or first_arg == 'i'
        Capucine::Tools.init second_arg
      
      elsif first_arg == 'compile' or first_arg == 'c'
        Capucine::Tools.compile
      
      elsif first_arg == 'watch' or first_arg == 'w'
        Capucine::Watchr.new second_arg
        
      else
        Capucine::Commands.help
      end
    end

    def self.help
      file_name = File.join Capucine.settings.gem_content_dir, 'templates', 'cmd_help.txt'

      puts File.read(file_name)
      exit
    end

  end
end

