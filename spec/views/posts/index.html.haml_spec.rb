require 'spec_helper'

describe "posts/index.html.haml" do
  before(:each) do
    assign(:posts, [
      stub_model(Post,
        :title => "Title",
        :body => "Foo"
      ),
      stub_model(Post,
        :title => "Title",
        :body => "Bar"
      )
    ])
  end

  it "renders a list of posts" do
    render :template => "posts/index", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should have_selector 'ol li .post-info h2', :count => 2 do |header|
        header.should have_selector 'a', :content => 'Title'
        header.should contain "Title"
      end
      page.should contain "Foo"
      page.should contain "Bar"
    end
  end

  it "shouldn't show control links when not logged in" do
    render :template => "posts/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "shouldn't show control links when logged in as non-admin" do
    sign_in get_user
    render :template => "posts/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "should show control links when logged in as admin" do
    sign_in get_admin_user
    render :template => "posts/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should have_selector 'a', :content => 'Edit'
      controls.should have_selector 'a', :content => 'Destroy'
    end
  end
end
