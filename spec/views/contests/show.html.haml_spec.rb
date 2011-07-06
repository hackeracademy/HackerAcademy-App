require 'spec_helper'

describe "contests/show.html.haml" do
  before(:each) do
    @contest = assign(:contest, stub_model(Contest,
      :description => "Description",
      :problem => "Do something",
      :start => DateTime.now,
      :end => DateTime.now + 5.days
    ))
  end

  it "renders attributes in <p>" do
    render :template => "contests/show", :layout => "layouts/application"
    rendered.should have_selector '#main h2', :content => @contest.description
    rendered.should have_selector '#main p', :content => @contest.problem
  end

  it "shouldn't show control links when not logged in" do
    render :template => "contests/show", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "shouldn't show control links when logged in as non-admin" do
    sign_in get_user
    render :template => "contests/show", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "should show control links when logged in as admin" do
    sign_in get_admin_user
    render :template => "contests/show", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should have_selector 'a', :content => 'Edit'
      controls.should have_selector 'a', :content => 'Destroy'
    end
  end
end
