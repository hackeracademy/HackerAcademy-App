class User
  include Mongoid::Document
  validates_uniqueness_of :name, :email, :case_sensitive => false
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :preferred_language, :year, :program, :rfid

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :lockable

  field :name

  field :rfid

  field :preferred_language
  field :program
  field :year

  field :is_admin, :type => Boolean, :default => false
  field :solved, type: Array

  has_and_belongs_to_many :achievements

  def total_score
    (self.achievements.map(&:value).sum +
     DojoAchievement.all.map(&:scores).inject(0) {|s| s[self.id] || 0 })
  end

  def level
    1 + (total_score / 512)
  end

  def self.all_ids
    User.all(sort: [[ :name, :asc ]]).collect {|u| [u.name, u.id]}
  end

end

