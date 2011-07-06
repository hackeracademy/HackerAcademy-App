require 'spec_helper'

describe ContestsController do

  # This should return the minimal set of attributes required to create a valid
  # Contest. As you add validations to Contest, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :description => "New Contest",
    }
  end

  describe "GET index" do
    it "assigns all contests as @contests" do
      contest = Contest.create! valid_attributes
      get :index
      assigns(:contests).to_a.should eq([contest])
    end
  end

  describe "GET show" do
    it "assigns the requested contest as @contest" do
      contest = Contest.create! valid_attributes
      get :show, :id => contest.id.to_s
      assigns(:contest).should eq(contest)
    end
  end

  describe "GET new" do
    it "should disallow anonymous creators" do
      get :new
      assigns(:contest).should be_nil
      response.should redirect_to(new_user_session_path)
    end

    it "should disallow non-admin creators" do
      sign_in get_user
      get :new
      assigns(:contest).should be_nil
    end

    it "assigns a new contest as @contest" do
      sign_in get_admin_user
      get :new
      assigns(:contest).should be_a_new(Contest)
    end
  end

  describe "GET edit" do
    it "should fail when not logged in" do
      contest = Contest.create! valid_attributes
      get :edit, :id => contest.id.to_s
      assigns(:contest).should be_nil
      response.should redirect_to(new_user_session_path)
    end

    it "should fail when logged in as non-admin" do
      sign_in get_user
      contest = Contest.create! valid_attributes
      get :edit, :id => contest.id.to_s
      assigns(:contest).should be_nil
    end

    it "assigns the requested contest as @contest" do
      sign_in get_admin_user
      contest = Contest.create! valid_attributes
      get :edit, :id => contest.id.to_s
      assigns(:contest).should eq(contest)
    end

  end

  describe "POST create" do
    describe "with valid params" do
      it "should fail when not logged in" do
        post :create, :contest => valid_attributes
        assigns(:contest).should be_nil
        response.should redirect_to(new_user_session_path)
      end

      it "should fail when logged in as non-admin" do
        sign_in get_user
        post :create, :contest => valid_attributes
        assigns(:contest).should be_nil
      end

      it "creates a new Contest" do
        sign_in get_admin_user
        expect {
          post :create, :contest => valid_attributes
        }.to change(Contest, :count).by(1)
      end

      it "assigns a newly created contest as @contest" do
        sign_in get_admin_user
        post :create, :contest => valid_attributes
        assigns(:contest).should be_a(Contest)
        assigns(:contest).should be_persisted
      end

      it "redirects to the created contest" do
        sign_in get_admin_user
        post :create, :contest => valid_attributes
        response.should redirect_to(Contest.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved contest as @contest" do
        sign_in get_admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        Contest.any_instance.stub(:save).and_return(false)
        post :create, :contest => {}
        assigns(:contest).should be_a_new(Contest)
      end

      it "re-renders the 'new' template" do
        sign_in get_admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        Contest.any_instance.stub(:save).and_return(false)
        post :create, :contest => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "should fail when not logged in" do
        contest = Contest.create! valid_attributes
        put :update, :id => contest.id, :contest => {
          :description => "New description"}
        response.should redirect_to(new_user_session_path)
      end

      it "updates the requested contest" do
        contest = Contest.create! valid_attributes
        # Assuming there are no other contests in the database, this
        # specifies that the Contest created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Contest.any_instance.should_receive(:update_attributes).with(
          {'these' => 'params'})
        sign_in get_admin_user
        put :update, :id => contest.id, :contest => {'these' => 'params'}
      end

      it "assigns the requested contest as @contest" do
        sign_in get_admin_user
        contest = Contest.create! valid_attributes
        put :update, :id => contest.id, :contest => valid_attributes
        assigns(:contest).should eq(contest)
      end

      it "redirects to the contest" do
        sign_in get_admin_user
        contest = Contest.create! valid_attributes
        put :update, :id => contest.id, :contest => valid_attributes
        response.should redirect_to(contest)
      end
    end

    describe "with invalid params" do
      it "assigns the contest as @contest" do
        sign_in get_admin_user
        contest = Contest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contest.any_instance.stub(:save).and_return(false)
        put :update, :id => contest.id.to_s, :contest => {}
        assigns(:contest).should eq(contest)
      end

      it "re-renders the 'edit' template" do
        sign_in get_admin_user
        contest = Contest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Contest.any_instance.stub(:save).and_return(false)
        put :update, :id => contest.id.to_s, :contest => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "should fail when not logged in" do
      contest = Contest.create! valid_attributes
      expect {
        delete :destroy, :id => contest.id.to_s
      }.to change(Contest, :count).by(0)
      response.should redirect_to(new_user_session_path)
    end

    it "should fail when logged in as non-admin" do
      sign_in get_user
      contest = Contest.create! valid_attributes
      expect {
        delete :destroy, :id => contest.id.to_s
      }.to change(Contest, :count).by(0)
    end

    it "destroys the requested contest" do
      sign_in get_admin_user
      contest = Contest.create! valid_attributes
      expect {
        delete :destroy, :id => contest.id.to_s
      }.to change(Contest, :count).by(-1)
    end

    it "redirects to the contests list" do
      sign_in get_admin_user
      contest = Contest.create! valid_attributes
      delete :destroy, :id => contest.id.to_s
      response.should redirect_to(contests_url)
    end
  end

end
