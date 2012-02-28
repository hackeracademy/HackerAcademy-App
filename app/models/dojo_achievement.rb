class DojoAchievement
  include Mongoid::Document

  field :name
  field :p0_scores, type: Hash
  field :p1_scores, type: Hash
  field :p2_scores, type: Hash
  field :p3_scores, type: Hash
end
