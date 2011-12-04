module Capucine
  class Templates

    def self.run_once
      settings = Capucine.settings

      files_to_watch = "#{settings.working_dir}/#{settings.config['templates_erb_files_dir']}/*.erb"
      templates = Dir.glob(files_to_watch)

      templates.each do |template|
        return if not File.exist? template
        html_name = File.basename(template).gsub('.erb', '')
        new_file = File.join settings.working_dir, html_name
        template_root = File.join settings.working_dir, settings.config['templates_erb_files_dir'] #for ERB binding
        
        result = Capucine::Tools.render_template template, template_root

        f = File.open(new_file, 'w+')
        f.write(result)
        f.close

      end
      
      puts "[template] - Rendered"

    end
    
    def self.proc_watch
      require 'fssm'
      
      watchr_thread = Thread.new {
        files_to_lookat = File.join Capucine.settings.working_dir, Capucine.settings.config['templates_erb_files_dir']

        FSSM.monitor(files_to_lookat, :directories => true) do
          update do |b, r|
            Capucine::Templates.run_once
          end

          create do |b, r|
            Capucine::Templates.run_once
          end

          delete do |b, r|
            Capucine::Templates.run_once
          end
        end
      }
      return watchr_thread

    end



  end
end
