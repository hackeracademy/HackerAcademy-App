class Contest
  include Mongoid::Document
  field :description, :type => String
  field :start, :type => Date
  field :end, :type => Date
end
