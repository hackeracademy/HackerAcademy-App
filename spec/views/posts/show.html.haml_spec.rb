require 'spec_helper'

describe "posts/show.html.haml" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :title => "The Title",
      :body => "The body"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/The Title/)
  end
end
