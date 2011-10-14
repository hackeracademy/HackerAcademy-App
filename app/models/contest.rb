class Contest
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  validates_presence_of :description, :problem, :start, :end
  field :description, :type => String
  field :puzzle_ident, :type => Integer
  field :problem, :type => String
  field :start, :type => DateTime
  field :end, :type => DateTime
end
