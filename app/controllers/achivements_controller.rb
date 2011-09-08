class AchivementsController < ApplicationController
  # GET /achivements
  # GET /achivements.xml
  def index
    @achivements = Achivement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @achivements }
    end
  end

  # GET /achivements/1
  # GET /achivements/1.xml
  def show
    @achivement = Achivement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @achivement }
    end
  end

  # GET /achivements/new
  # GET /achivements/new.xml
  def new
    @achivement = Achivement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @achivement }
    end
  end

  # GET /achivements/1/edit
  def edit
    @achivement = Achivement.find(params[:id])
  end

  # POST /achivements
  # POST /achivements.xml
  def create
    @achivement = Achivement.new(params[:achivement])

    respond_to do |format|
      if @achivement.save
        format.html { redirect_to(@achivement, :notice => 'Achivement was successfully created.') }
        format.xml  { render :xml => @achivement, :status => :created, :location => @achivement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @achivement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /achivements/1
  # PUT /achivements/1.xml
  def update
    @achivement = Achivement.find(params[:id])

    respond_to do |format|
      if @achivement.update_attributes(params[:achivement])
        format.html { redirect_to(@achivement, :notice => 'Achivement was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @achivement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /achivements/1
  # DELETE /achivements/1.xml
  def destroy
    @achivement = Achivement.find(params[:id])
    @achivement.destroy

    respond_to do |format|
      format.html { redirect_to(achivements_url) }
      format.xml  { head :ok }
    end
  end
end
