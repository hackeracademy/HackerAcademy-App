require 'spec_helper'

describe "achivements/show.html.haml" do
  before(:each) do
    @achivement = assign(:achivement, stub_model(Achivement,
      :name => "Name",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
  end
end
