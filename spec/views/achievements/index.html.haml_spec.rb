require 'spec_helper'

describe "achievements/index.html.haml" do
  before(:each) do
    assign(:achievements, [
      stub_model(Achievement,
        :name => "Name",
        :description => "Foo"
      ),
      stub_model(Achievement,
        :name => "Name",
        :description => "Bar"
      )
    ])
  end

  it "renders a list of achievements" do
    render :template => "achievements/index", :layout => "layouts/application"
    rendered.should have_selector '#main' do |page|
      page.should have_selector 'ol li .achievement-info h2', :count => 2 do |header|
        header.should have_selector 'a', :content => 'Name'
        header.should contain "Name"
      end
      page.should contain "Foo"
      page.should contain "Bar"
    end
  end

  it "shouldn't show control links when not logged in" do
    render :template => "achievements/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "shouldn't show control links when logged in as non-admin" do
    sign_in get_user
    render :template => "achievements/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should_not have_selector 'a', :content => 'Edit'
      controls.should_not have_selector 'a', :content => 'Destroy'
    end
  end

  it "should show control links when logged in as admin" do
    sign_in get_admin_user
    render :template => "achievements/index", :layout => "layouts/application"
    rendered.should have_selector '.controls' do |controls|
      controls.should have_selector 'a', :content => 'Edit'
      controls.should have_selector 'a', :content => 'Destroy'
    end
  end
end
