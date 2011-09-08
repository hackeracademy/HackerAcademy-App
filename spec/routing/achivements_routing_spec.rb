require "spec_helper"

describe AchivementsController do
  describe "routing" do

    it "routes to #index" do
      get("/achivements").should route_to("achivements#index")
    end

    it "routes to #new" do
      get("/achivements/new").should route_to("achivements#new")
    end

    it "routes to #show" do
      get("/achivements/1").should route_to("achivements#show", :id => "1")
    end

    it "routes to #edit" do
      get("/achivements/1/edit").should route_to("achivements#edit", :id => "1")
    end

    it "routes to #create" do
      post("/achivements").should route_to("achivements#create")
    end

    it "routes to #update" do
      put("/achivements/1").should route_to("achivements#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/achivements/1").should route_to("achivements#destroy", :id => "1")
    end

  end
end
