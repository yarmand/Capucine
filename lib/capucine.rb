require 'settings.rb'

module Capucine
  
  def new
    @settings = Capucine::Settings.new
  end
  
  def settings
    @settings
  end

  module_function :new, :settings
end
