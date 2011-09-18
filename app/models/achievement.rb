class Achievement
  include Mongoid::Document
  field :name, :type => String
  field :description, :type => String
  field :value, :type => Integer

  has_and_belongs_to_many :users

  def self.all_ids
    self.find(:all).collect {|a| [a.name, a.id]}
  end
end
