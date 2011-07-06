require 'spec_helper'

describe "contests/index.html.haml" do
  before(:each) do
    include ApplicationHelper
    assign(:contests, [
      stub_model(Contest,
        :description => "Description",
        :problem => "Do something",
        :start => DateTime.now,
        :end => DateTime.now + 5.days
      ),
      stub_model(Contest,
        :description => "Description",
        :problem => "Do something",
        :start => DateTime.now,
        :end => DateTime.now + 3.days
      )
    ])
  end

  it "renders a list of contests" do
    render :template => "contests/index", :layout => "layouts/application"
    rendered.should have_selector "ol li p", :content => "Description", :count => 2
  end
end
