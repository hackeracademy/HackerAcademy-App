require 'spec_helper'

describe "contests/index.html.haml" do
  before(:each) do
    assign(:contests, [
      stub_model(Contest,
        :description => "Description"
      ),
      stub_model(Contest,
        :description => "Description"
      )
    ])
  end

  it "renders a list of contests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
