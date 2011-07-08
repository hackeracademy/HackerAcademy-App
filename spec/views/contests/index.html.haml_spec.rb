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
    rendered.should have_selector "ol li .contest-info p", :content => "Description",
      :count => 2
  end

  it "shouldn't show control links when not logged in" do
    render :template => "contests/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "shouldn't show control links when logged in as non-admin" do
    sign_in get_user
    render :template => "contests/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "should show control links when logged in as admin" do
    sign_in get_admin_user
    render :template => "contests/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should have_selector 'a', :content => 'Edit'
      controls.should have_selector 'a', :content => 'Destroy'
    end
  end
end
