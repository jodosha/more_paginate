class Event < ActiveRecord::Base
  self.per_page = 23
  has_many :photos
  has_and_belongs_to_many :people
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings
end

class Festival < Event
  self.per_page = 11
end

class Photo < ActiveRecord::Base
  belongs_to :event
end

class Person < ActiveRecord::Base
  has_and_belongs_to_many :events
end

class Tag < ActiveRecord::Base
  has_many :taggings
end

class Tagging < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :tag
end