require 'spec_helper'

describe PostsController do

  # This should return the minimal set of attributes required to create a valid
  # Post. As you add validations to Post, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :title => "Test Post",
      :body => "Lorem ipsum delores est"
    }
  end

  describe "GET index" do
    it "assigns all posts as @posts" do
      post = Post.create! valid_attributes
      get :index
      assigns(:posts).to_a.should eq([post])
    end
  end

  describe "GET show" do
    it "assigns the requested post as @post" do
      post = Post.create! valid_attributes
      get :show, :id => post.id.to_s
      assigns(:post).should eq(post)
    end
  end

  describe "GET new" do
    it "should fail when not logged in" do
      get :new
      assigns(:post).should be_nil
      response.should redirect_to(new_user_session_path)
    end

    it "should fail when logged in as non-admin" do
      sign_in get_user
      get :new
      assigns(:post).should be_nil
    end

    it "assigns a new post as @post" do
      sign_in get_admin_user
      get :new
      assigns(:post).should be_a_new(Post)
    end
  end

  describe "GET edit" do
    it "should fail when not logged in" do
      post = Post.create! valid_attributes
      get :edit, :id => post.id.to_s
      assigns(:post).should be_nil
      response.should redirect_to(new_user_session_path)
    end

    it "assigns the requested post as @post" do
      sign_in get_admin_user
      post = Post.create! valid_attributes
      get :edit, :id => post.id.to_s
      assigns(:post).should eq(post)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "should fail when not logged in" do
        post :create, :post => valid_attributes
        assigns(:post).should be_nil
        response.should redirect_to(new_user_session_path)
      end

      it "should fail when logged in as non-admin" do
        sign_in get_user
        post :create, :post => valid_attributes
        assigns(:post).should be_nil
      end

      it "creates a new Post" do
        sign_in get_admin_user
        expect {
          post :create, :post => valid_attributes
        }.to change(Post, :count).by(1)
      end

      it "assigns a newly created post as @post" do
        sign_in get_admin_user
        post :create, :post => valid_attributes
        assigns(:post).should be_a(Post)
        assigns(:post).should be_persisted
      end

      it "redirects to the created post" do
        sign_in get_admin_user
        post :create, :post => valid_attributes
        response.should redirect_to(Post.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved post as @post" do
        sign_in get_admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        post :create, :post => {}
        assigns(:post).should be_a_new(Post)
      end

      it "re-renders the 'new' template" do
        sign_in get_admin_user
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        post :create, :post => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "should fail when not logged in" do
        post = Post.create! valid_attributes
        put :update, :id => post.id, :post => {:title => "New Title"}
        response.should redirect_to(new_user_session_path)
      end

      it "should fail when logged in as non-admin" do
        sign_in get_user
        post = Post.create! valid_attributes
        post.should_receive(:update_attributes).never
        put :update, :id => post.id, :post => {:title => "New Title"}
      end

      it "updates the requested post" do
        post = Post.create! valid_attributes
        # Assuming there are no other posts in the database, this
        # specifies that the Post created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Post.any_instance.should_receive(:update_attributes).with(
          {'title' => "New Title"})
        sign_in get_admin_user
        put :update, :id => post.id, :post => {'title' => "New Title"}
      end

      it "assigns the requested post as @post" do
        sign_in get_admin_user
        post = Post.create! valid_attributes
        put :update, :id => post.id, :post => valid_attributes
        assigns(:post).should eq(post)
      end

      it "redirects to the post" do
        sign_in get_admin_user
        post = Post.create! valid_attributes
        put :update, :id => post.id, :post => valid_attributes
        response.should redirect_to(post)
      end
    end

    describe "with invalid params" do
      it "assigns the post as @post" do
        sign_in get_admin_user
        post = Post.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        put :update, :id => post.id.to_s, :post => {}
        assigns(:post).should eq(post)
      end

      it "re-renders the 'edit' template" do
        sign_in get_admin_user
        post = Post.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        put :update, :id => post.id.to_s, :post => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "should fail when not logged in" do
      post = Post.create! valid_attributes
      expect {
        delete :destroy, :id => post.id.to_s
      }.to change(Post, :count).by(0)
      response.should redirect_to(new_user_session_path)
    end

    it "should fail when logged in as non-admin" do
      sign_in get_user
      post = Post.create! valid_attributes
      expect {
        delete :destroy, :id => post.id.to_s
      }.to change(Post, :count).by(0)
    end

    it "destroys the requested post" do
      sign_in get_admin_user
      post = Post.create! valid_attributes
      expect {
        delete :destroy, :id => post.id.to_s
      }.to change(Post, :count).by(-1)
    end

    it "redirects to the posts list" do
      sign_in get_admin_user
      post = Post.create! valid_attributes
      delete :destroy, :id => post.id.to_s
      response.should redirect_to(posts_url)
    end
  end

end
