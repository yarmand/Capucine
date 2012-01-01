module Capucine
  class Coffee
    require 'packr'
    require 'coffee-script'
    require 'fssm'
    
    def self.compile_dir input, output
      settings = Capucine.settings
      
      if File.extname(input) == '.coffee'
        coffee_files = input
      else
        coffee_files = File.join settings.working_dir, input, "**/**.coffee"
      end
      
      Dir.glob(coffee_files).each do |file_coffee_o|

        file_coffee = File.expand_path file_coffee_o
        base_in_dir = File.join settings.working_dir, input

        relative_path = File.basename(file_coffee)
        relative_path = relative_path.gsub(/\.coffee$/, '.js')
        relative_path_min = relative_path.gsub(/\.js$/, '.min.js')

        file_out = File.join settings.working_dir, output, relative_path
        file_out_min = File.join settings.working_dir, output, relative_path_min

        relative_coffee_file = file_coffee.gsub(base_in_dir, '')
        
        opts = settings.config['coffeescript_options']
        
        coffee_output_min = ""
        
        error = false
        begin
          coffee_output = CoffeeScript.compile(File.read(file_coffee), opts)
        rescue Exception => e
          error = true
          message = "#{e.message}"
          coffee_output = "var message = \"CoffeeScript Error (#{relative_coffee_file.gsub(/^\//, '')}) => \";"
          coffee_output += "message += \"#{message}\";"
          coffee_output += "throw message;"
        end
        
        coffee_output_min << Packr.pack(coffee_output)
        FileUtils.mkdir_p File.dirname(file_out)
        
        puts "[coffee] - #{relative_path} => #{message}" if error
        
        f1 = File.open(file_out, 'w+')
        f1.write(coffee_output)
        f1.close

        f2 = File.open(file_out_min, 'w+')
        f2.write(coffee_output_min)
        f2.close
      end
      
    end
    
    def self.run_once file = nil
      settings = Capucine.settings

      unless file
        self.compile_dir settings.config['coffeescript_files_dir'], settings.config['coffeescript_output_dir']
      else
        self.compile_dir file, settings.config['coffeescript_output_dir']
      end
      
      puts "[coffee] - Compiled"
      # Capucine::Incloudr.run_once if settings.config['incloudr_enable']
    end
    
    def self.proc_watch
      settings = Capucine.settings

      files_to_lookat = File.join settings.working_dir, settings.config['coffeescript_files_dir']
      js_generated_dir = File.join settings.working_dir, settings.config['coffeescript_output_dir']

      coffee_thread = Thread.new {
        FSSM.monitor(files_to_lookat, :directories => true) do
          update do |b, r|
            file = File.join b, r
            Capucine::Coffee.run_once file  if File.extname(r) == '.coffee'
          end

          create do |b, r|
            file = File.join b, r
            Capucine::Coffee.run_once file  if File.extname(r) == '.coffee'
          end

          delete do |b, r|
            
            file_name = File.expand_path File.join(b, r)
            folder_name = File.dirname file_name
            js_file = File.join js_generated_dir, r.gsub('.coffee', '.js')

            if Dir["#{folder_name}/*"].empty? and folder_name != js_generated_dir
              # delete full dir
              to_delete = File.expand_path(File.dirname(js_file))
              FileUtils.rm_r to_delete
            else
              # delete one file
              File.delete(js_file) if File.exist?(js_file)
            end

          end
        end

      }
      
      return coffee_thread

    end

  end
  
end

