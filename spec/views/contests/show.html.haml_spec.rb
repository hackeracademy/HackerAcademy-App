require 'spec_helper'

describe "contests/show.html.haml" do
  before(:each) do
    @contest = assign(:contest, stub_model(Contest,
      :description => "Description",
      :start => DateTime.now,
      :end => DateTime.now + 5.days
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain(/Description/)
  end
end
