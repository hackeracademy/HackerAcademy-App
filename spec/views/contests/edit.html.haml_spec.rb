require 'spec_helper'

describe "contests/edit.html.haml" do
  before(:each) do
    @contest = assign(:contest, stub_model(Contest,
      :description => "MyString",
      :problem => "Do something",
      :start => DateTime.now,
      :end => DateTime.now + 5.days
    ))
  end

  it "renders the edit contest form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => contests_path(@contest), :method => "post" do
      assert_select "input#contest_description", :name => "contest[description]"
    end
  end
end
