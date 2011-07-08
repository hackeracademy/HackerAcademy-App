require 'spec_helper'

describe "users/index.html.haml" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :name => "user1",
        :password => "user1pw",
        :email => "user1@example.com"
      ),
      stub_model(User,
        :name => "user2",
        :password => "user2pw",
        :email => "user2@example.com"
      )
    ])
  end

  it "renders a list of users" do
    render
    rendered.should have_selector "ol li .user-info p a", :count => 2
  end
end
