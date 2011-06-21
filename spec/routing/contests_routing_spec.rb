require "spec_helper"

describe ContestsController do
  describe "routing" do

    it "routes to #index" do
      get("/contests").should route_to("contests#index")
    end

    it "routes to #new" do
      get("/contests/new").should route_to("contests#new")
    end

    it "routes to #show" do
      get("/contests/1").should route_to("contests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/contests/1/edit").should route_to("contests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/contests").should route_to("contests#create")
    end

    it "routes to #update" do
      put("/contests/1").should route_to("contests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/contests/1").should route_to("contests#destroy", :id => "1")
    end

  end
end
