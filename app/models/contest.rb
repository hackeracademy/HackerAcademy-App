class Contest
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  field :description, :type => String
  field :problem, :type => String
  field :start, :type => DateTime
  field :end, :type => DateTime
end
