module Vemv
  class Engine < ::Rails::Engine
    isolate_namespace Vemv
    # require 'pry'
    # binding.pry
    Dir.glob(File.join(root, 'app', 'lib', '**', '*.rb')).map{ |file|
      require_relative file
    }
    
  end
end
