class Event < ActiveRecord::Base
  self.per_page = 23
  has_many :photos
end

class Festival < Event
  self.per_page = 11
end

class Photo < ActiveRecord::Base
  belongs_to :event
end
