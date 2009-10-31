class Event < ActiveRecord::Base
  self.per_page = 23
end

class Festival < Event
  self.per_page = 11
end
