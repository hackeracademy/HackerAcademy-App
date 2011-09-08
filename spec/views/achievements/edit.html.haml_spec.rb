require 'spec_helper'

describe "achievements/edit.html.haml" do
  before(:each) do
    @achievement = assign(:achievement, stub_model(Achievement,
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit achievement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => achievements_path(@achievement), :method => "post" do
      assert_select "input#achievement_name", :name => "achievement[name]"
      assert_select "input#achievement_description", :name => "achievement[description]"
    end
  end
end
