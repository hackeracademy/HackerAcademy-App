class User
  include Mongoid::Document
  validates_uniqueness_of :name, :email, :case_sensitive => false
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :lockable

  field :name
  field :is_admin, :type => Boolean, :default => false

  has_and_belongs_to_many :achievements

  def total_score
    self.achievements.map(&:value).sum
  end

  def level
    1 + (total_score / 512)
  end

  def self.all_ids
    self.find(:all).collect {|u| [u.name, u.id]}
  end

end

