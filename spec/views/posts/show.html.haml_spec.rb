require 'spec_helper'

describe "posts/show.html.haml" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :title => "The Title",
      :body => "The body"
    ))
  end

  it "renders post information" do
    render :template => "posts/show", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should have_selector 'h2' do |header|
        header.should contain @post.title
      end
      page.should have_selector 'p' do |body|
        body.should contain @post.body
      end
    end
  end

  it "shouldn't show control links when not logged in" do
    render :template => "posts/show", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should_not have_xpath '//a[text()="Edit"]'
      page.should_not have_xpath '//a[text()="Destroy"]'
    end
  end

  it "shouldn't show control links when logged in as non-admin" do
    sign_in get_user
    render :template => "posts/show", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should_not have_xpath '//a[text()="Edit"]'
      page.should_not have_xpath '//a[text()="Destroy"]'
    end
  end

  it "should show control links when logged in as admin" do
    sign_in get_admin_user
    render :template => "posts/show", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should have_xpath '//a[text()="Edit"]'
      page.should have_xpath '//a[text()="Destroy"]'
    end
  end
end
