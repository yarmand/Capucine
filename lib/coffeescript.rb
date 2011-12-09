module Capucine
  class Coffee
    require 'packr'

    def self.run_once file = nil
      require 'coffee-script'
      
      settings = Capucine.settings
      
      coffee_files = file
      coffee_files = "#{settings.working_dir}/#{settings.config['coffeescript_coffee_files_dir']}/**/**.coffee" if not file
      
      Dir.glob(coffee_files).each do |file_coffee_o|

        file_coffee = File.expand_path file_coffee_o
        base_in_dir = File.join settings.working_dir, settings.config['coffeescript_coffee_files_dir']

        relative_path = File.basename(file_coffee)
        relative_path = relative_path.gsub(/\.coffee$/, '.js')
        relative_path_min = relative_path.gsub(/\.js$/, '.min.js')

        file_out = File.join settings.working_dir, settings.config['coffeescript_js_generated_dir'], relative_path
        file_out_min = File.join settings.working_dir, settings.config['coffeescript_js_generated_dir'], relative_path_min


        relative_coffee_file = file_coffee.gsub(base_in_dir, '')

        bare_opt = false
        bare_opt = true if settings.config['coffeescript_coffee_bare']
        
        coffee_output_min = ""

        begin
          coffee_output = CoffeeScript.compile(File.read(file_coffee), :bare => bare_opt)
        rescue Exception => e
          coffee_output = "var message = \"CoffeeScript Error (#{relative_coffee_file.gsub(/^\//, '')}) => \";"
          coffee_output += "message += \"#{e.message}'\";"
          coffee_output += "throw message;"
          message = "#{e.message}"
        end
        
        coffee_output_min << Packr.pack(coffee_output)

        puts "[coffee] - #{message}" if message

        FileUtils.mkdir_p File.dirname(file_out)

        f1 = File.open(file_out, 'w+')
        f1.write(coffee_output)
        f1.close

        f2 = File.open(file_out_min, 'w+')
        f2.write(coffee_output_min)
        f2.close

      end

      puts "[coffee] - Compiled"
      Capucine::Incloudr.run_once if settings.config['incloudr_enable']
    end

    def self.proc_watch
      require 'fssm'
      settings = Capucine.settings

      coffee_thread = Thread.new {
        files_to_lookat = File.join settings.working_dir, settings.config['coffeescript_coffee_files_dir']
        
        FSSM.monitor(files_to_lookat, :directories => true) do
          update do |b, r|
            Capucine::Coffee.run_once File.join b, r if File.extname(r) == '.coffee'
          end

          create do |b, r|
            Capucine::Coffee.run_once File.join b, r if File.extname(r) == '.coffee'
          end

          delete do |b, r|
            js_generated_dir = File.expand_path settings.config['coffeescript_js_generated_dir']

            file_name = File.expand_path File.join(b, r)
            folder_name = File.dirname file_name
            js_file = File.join js_generated_dir, r.gsub('.coffee', '.js')

            if Dir["#{folder_name}/*"].empty? and folder_name != js_generated_dir
              to_delete = File.expand_path(File.dirname(js_file))
              FileUtils.rm_r to_delete
            else
              File.delete(js_file) if File.exist?(js_file)
            end

          end
        end

      }
      
      return coffee_thread

    end

  end
  
end

