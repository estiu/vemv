module Sluggable
  
  def self.included base
    base.class_eval do
      
      extend FriendlyId
      
      validates :slug, presence: true, uniqueness: true
      before_validation :cleanup_slug
      
      friendly_id :slug, use: :slugged
      
      def cleanup_slug
        if self.slug.present?
          self.slug = self.slug.downcase.gsub(/[^a-z0-9|\-\_]/, '')
        end
      end

    end
  end
  
end