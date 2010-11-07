module Pilot
  module Imageable
    module ActiveRecord            
      
      def stores_images(*args)
        options = args.extract_options!
        class_attribute :versions_path, :instance_writer => false
        self.versions_path = options.delete(:versions_at)              
        stores *(args << options)
        extend Image
      end
        
      def has_one_image(association_name, options = {}, &extension)
        use_filler = options.delete :filler

        associate_images :has_one, association_name, options, &extension

        if use_filler
          class_eval <<-GETTER, __FILE__, __LINE__ + 1
            def #{association_name}_with_filler
              if #{association_name}_without_filler.presence
                #{association_name}_without_filler
              else
                image_class = #{self.reflect_on_association(association_name).klass}
                filler_class = #{use_filler.is_a?(TrueClass) ? nil : use_filler}
                (@#{association_name}_filler ||= ImageFiller.fill(self, image_class, :#{association_name}, filler_class))
              end
            end
            alias_method_chain :#{association_name}, :filler
          GETTER
        end    

      end   

      def has_many_images(association_name, options = {}, &extension)
        associate_images :has_many, association_name, options, &extension
      end

      def associate_images(association_macro, association_name, options, &extension)
        versions_class_method = :"#{association_name.to_s.singularize}_versions"
        class_inheritable_array versions_class_method

        association_options = options.merge :as => :imageable 

        # We modulize the block, if present
        if extension.present?
          extension = Module.new &extension
          association_options[:extend] = Array.wrap(association_options[:extend]) << extension
        end

        send(association_macro, association_name, association_options)       
      end
    end
  end
end