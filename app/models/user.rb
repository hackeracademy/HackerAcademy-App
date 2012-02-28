class User
  include Mongoid::Document
  validates_uniqueness_of :name, :email, :case_sensitive => false
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :preferred_language, :year, :program, :rfid, :shirt_size

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :lockable

  field :name

  field :rfid

  field :shirt_size
  field :preferred_language
  field :program
  field :year

  field :is_admin, :type => Boolean, :default => false
  field :solved, type: Array

  has_and_belongs_to_many :achievements

  def dojos
    DojoAchievement.all.select do |da|
      not (da.p0_scores[self.id.to_s].nil? && da.p1_scores[self.id.to_s].nil? &&
            da.p2_scores[self.id.to_s].nil? && da.p3_scores[self.id.to_s].nil?)
    end
  end

  def dojo_points
    self.dojos.map do |dojo|
      [(dojo.p0_scores[self.id.to_s] || 0),
       (dojo.p1_scores[self.id.to_s] || 0),
       (dojo.p2_scores[self.id.to_s] || 0),
       (dojo.p3_scores[self.id.to_s] || 0)].sum
    end.sum
  end

  def raffle_score
    points = self.achievements.map(&:value).sum
    dojo1_winners = ["Zongyi", "Cheng Zhao", "Roberto Bortolussi",
      "Mengye Ren", "Adam Hueniken"]
    dojo2_winners = ["Roberto Bortolussi", "Liam Cooke", "Adam Hueniken",
      "Zongyi", "Cheng Zhao"]
    if not dojo1_winners.member? self.name
      dojo = DojoAchievement.where(name: "Dojo 1: Needles").first
      points += [(dojo.p0_scores[self.id.to_s] || 0),
       (dojo.p1_scores[self.id.to_s] || 0),
       (dojo.p2_scores[self.id.to_s] || 0)].sum
    end
    if not dojo2_winners.member? self.name
      dojo = DojoAchievement.where(name: "Dojo 2: Electric Courage").first
      points += [(dojo.p0_scores[self.id.to_s] || 0),
       (dojo.p1_scores[self.id.to_s] || 0),
       (dojo.p2_scores[self.id.to_s] || 0)].sum
    end
  end

  def total_score
    self.achievements.map(&:value).sum + self.dojo_points
  end

  def level
    1 + (total_score / 512)
  end

  def self.all_ids
    User.all(sort: [[ :name, :asc ]]).collect {|u| [u.name, u.id]}
  end

  def has_solved? dojo, level
    self.solved.map(&:first).member? "dojo#{dojo}_level#{level}" if self.solved
  end

  def puzzle_available? dojo, level
    return level == 0 || self.has_solved?(dojo, level) ||
      self.has_solved?(dojo, level-1)
  end

end

