%w(settings.rb tools.rb commands.rb).each do |lib|
  require "#{lib}"
end

module Capucine
  
  def new
    @settings = Capucine::Settings.new
  end
  
  def get_name
    self.to_s.downcase
  end

  def settings
    @settings
  end

  module_function :new, :settings, :get_name

end

