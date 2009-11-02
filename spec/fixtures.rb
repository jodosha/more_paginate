class Event < ActiveRecord::Base
  self.per_page = 23
  has_many :photos
  has_and_belongs_to_many :people
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
