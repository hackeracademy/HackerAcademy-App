class DojoAchievement
  include Mongoid::Document

  field :name
  field :scores, type: Hash
end
