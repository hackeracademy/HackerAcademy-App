require 'spec_helper'

describe User do

  def valid_attributes
    {:name => "tester",
     :password => "testing",
     :email => "test@testing.com"
    }
  end

  it "should save newly-created users" do
    user = User.create valid_attributes
    user.save!.should be_true
    found = User.find user.id
    found.name.should eq user.name
    found.email.should eq user.email
  end

  it { should validate_presence_of :name }
end
