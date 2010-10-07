

# # Rails.application.config.after_initialize do 
# #   
# #   Versions are descendants of the main image versions model
#   Pilot::Imageable.config.image_versions_model.constantize.instance_eval do    
#     
#     include Processor
#     
#     before_upload :process
#    
#     def list
#       @list ||= descendants.map do |d| 
#         d.name.underscore.to_sym
#       end
#     end    
#       
#   end
#   
#   Pilot::Imageable.config.image_model.constantize.class_eval do    
#     
#     include Processor
#     
#     # We associate all transformations
#     Pilot::Imageable.config.image_versions_model.constantize.list.each do |version|
#       has_one version
#     end
#     
#     has_many :versions, :dependent => :destroy, 
#       :class_name => Pilot::Imageable.config.image_versions_model 
#       
#     belongs_to :imageable, :polymorphic => true
#     
#     after_create :create_versions
#     
#     def create_versions
#       version_names = imageable.class.send "#{self.class.name.underscore}_versions"      
#       version_names.each do |v|        
#         version_temp_filename = v.to_s + "-" + _temp_file.filename
#         version_temp_file = Tempfile.new(version_temp_filename).tap do |tmp|
#           tmp.class_eval { attr_accessor :original_filename}
#           tmp.original_filename = version_temp_filename
#           tmp.binmode
#           tmp.write self._temp_file.read
#         end
#         self.send "create_#{v.to_s}", :_temp_file => temp_file
#       end
#     end
#     
#   end
#   
#   Pilot::Imageable::ImageFiller.versions_model =  Pilot::Imageable.config.image_versions_model.constantize
#   Pilot::Imageable::ImageFiller.path = Pilot::Imageable.config.image_filler_path
#   Pilot::Imageable::ImageFiller.load
#   
# end