require 'spec_helper'

describe "achievements/new.html.haml" do
  before(:each) do
    assign(:achievement, stub_model(Achievement,
      :name => "MyString",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new achievement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => achievements_path, :method => "post" do
      assert_select "input#achievement_name", :name => "achievement[name]"
      assert_select "input#achievement_description", :name => "achievement[description]"
    end
  end
end
