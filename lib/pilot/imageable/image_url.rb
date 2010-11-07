module Pilot
  module Imageable
    class ImageUrl < String
      
      alias_method :url, :to_s
  
    end
  end
end