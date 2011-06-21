require 'spec_helper'

describe "posts/edit.html.haml" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
        :title => "Test Post",
        :body => "Lorem ipsum delores est"
    ))
  end

  it "renders the edit post form" do
    render

    assert_select "form", :action => posts_path(@post), :method => "post" do
      assert_select "input#post_title", :name => "post[title]"
      assert_select "textarea#post_body", :name => "post[body]"
    end
  end
end
