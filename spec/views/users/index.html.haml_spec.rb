require 'spec_helper'

describe "users/index.html.haml" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :username => "user1",
        :password => "user1pw",
        :email => "user1@example.com"
      ),
      stub_model(User,
        :username => "user2",
        :password => "user2pw",
        :email => "user2@example.com"
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => "user1".to_s
    assert_select "tr>td", :text => "user2".to_s
  end
end
