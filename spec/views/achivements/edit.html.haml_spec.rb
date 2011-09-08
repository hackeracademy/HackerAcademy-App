require 'spec_helper'

describe "achivements/edit.html.haml" do
  before(:each) do
    @achivement = assign(:achivement, stub_model(Achivement,
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit achivement form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => achivements_path(@achivement), :method => "post" do
      assert_select "input#achivement_name", :name => "achivement[name]"
      assert_select "input#achivement_description", :name => "achivement[description]"
    end
  end
end
