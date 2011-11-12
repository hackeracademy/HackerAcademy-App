require 'openssl'
require 'cgi'

class ContestsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!, :except => [:show, :index]
  authorize_resource except: [:problem, :solution]
  skip_authorization_check only: [:problem, :solution]

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    if @contest.start > DateTime.now
      unless current_user.is_admin
        redirect_to contests_path, alert: "That contest has not yet started"
        return
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  def problem
    @contest = Contest.find(params[:contest_id])
    contest_ident = @contest.puzzle_ident
    @level = params[:level].to_i
    if !current_user.puzzle_available? contest_ident, @level
      redirect_to @contest, alert: "That puzzle isn't available to you yet"
      return
    end

    # To add more dojos, add another elsif contest_ident == statement. In the
    # block, simply add another elsif block for the appropriate contest_ident
    # which sets the "args" variable to be the array of arguments which will be
    # passed to the puzzle generator function (see contests_helper.rb for more
    # detail.
    args = []
    if contest_ident == 1
      unless (0..2).member? @level
        redirect_to @contest, alert: "Invalid level"
        return
      end
      puzzle_length = [350, 100, 100]
      puzzle_words = [20, 5, 5]
      args = [puzzle_length[@level], puzzle_words[@level]]
    elsif contest_ident == 2
      unless (0..2).member? @level
        redirect_to @contest, alert: "Invalid level"
        args = []
      end
    else
      redirect_to @contest, alert: "Invalid contest"
    end

    problem = "dojo#{contest_ident}_level#{@level}"
    @prob = ContestsHelper.generate_puzzle(contest_ident,
      @level, args)

    # For making sure the solution is within the time limit
    session[:time] = Time.now.to_i
    # Used to avoid people trying to cheat by changing the puzzle in the form
    msg = ""
    if contest_ident == 1
      msg = @prob[:puzzle] + @prob[:words].join('')
    elsif contest_ident == 2
      if @level == 0
        msg = @prob[:query] + @prob[:posts].map{|x| x[0]}.join('+')
      elsif @level > 0
        msg = @prob[:searches].map{|x| x[0]}.join('+') + @prob[:locations].join('+')
      end
    end
    key = ENV['HMAC_KEY'] || "derp"
    session[:key] = OpenSSL::HMAC.hexdigest('sha256', msg, key)

    render problem
  end

  def solution
    contest = Contest.find(params[:contest])
    correct = false
    perf = -1

    if contest.puzzle_ident == 2
      msg = nil
      level = params[:level]

      if level == "0"
        msg = params[:query] + params[:posts]
      elsif level == "1" or level == "2"
        msg = params[:searches] + params[:locations]
      end
      key = ENV['HMAC_KEY'] || "derp"
      hmac = OpenSSL::HMAC.hexdigest('sha256', msg, key)
      if hmac != session[:key]
        redirect_to contest, alert: 'Cheating detected...'
        return
      end
      session.delete :key

      time_elapsed = Time.now.to_i - session[:time]
      session.delete :time
      if time_elapsed > 180
        redirect_to contest,
          alert: "Sorry, you took too long with your answer (#{time_elapsed} seconds)"
        return
      end

      # CHECK SOLUTION

      if level == '0'
        correct = ContestsHelper::Dojo2.verify_level0(params[:posts], params[:query], params[:solution])
      elsif level == '1'
        correct,perf = ContestsHelper::Dojo2.verify_level1(params[:searches], params[:locations], params[:solution])
      elsif level == '2'
        correct,perf = ContestsHelper::Dojo2.verify_level2(params[:searches], params[:locations], params[:solution])
      end


    elsif contest.puzzle_ident == 1
      puzzle = params[:puzzle].gsub('N', "\n")
      words = params[:words].split('+')
      prob = {puzzle: puzzle, words: words}
      msg = puzzle + words.join('')
      key = ENV['HMAC_KEY'] || "derp"
      hmac = OpenSSL::HMAC.hexdigest('sha256', msg, key)
      if hmac != session[:key]
        redirect_to contest, alert: 'Cheating detected...'
        return
      end
      session.delete :key
      level = params[:level]
      time_elapsed = Time.now.to_i - session[:time]
      session.delete :time
      if time_elapsed > 120
        redirect_to contest,
          alert: "Sorry, you took too long with your answer (#{time_elapsed} seconds)"
        return
      end
      # This is rather more difficult to split up, since we need to do different
      # preprocessing to the input before we can check it

      soln = nil
      if level == '0'
        soln = params[:solution].split(/\s*,\s*/).map(&:to_i)
        if soln.length != prob[:words].length
          correct = false
        else
          correct = ContestsHelper::Dojo1.verify_level0(
            Hash[*prob[:words].sort.zip(soln).flatten], prob[:puzzle]
          )
        end
      elsif level == '1' || level == '2'
        soln = params[:solution].split(/\s*;\s*/).map do |pair|
          pair.split(/\s*,\s*/).map(&:to_i)
        end
        if soln.length != prob[:words].length
          correct = false
        else
          soln = prob[:words].sort.zip(soln)
          correct = ContestsHelper::Dojo1.verify_puzzle(level,
            soln.inject({}) {|h,e| h[e.first] = e.second; h}, prob[:puzzle]
          )
        end
      end
      

    end

    if correct

      if ENV["RAILS_ENV"] == "production"
        if false
          Pony.mail(
            :to => 'rafal.dittwald@gmail.com', :cc => 'james.nvc@gmail.com',
            :from => 'dojobot@hackeracademy.org',
            :subject => "#{current_user.name} has solved problem #{level} at #{Time.now}")
          if perf != -1
             Pony.mail(
            :to => 'rafal.dittwald@gmail.com', :cc => 'james.nvc@gmail.com',
            :from => 'dojobot@hackeracademy.org',
            :subject => "#{perf.round(2)} #{current_user.name} P#{level} at #{Time.now}")
          end
        end
      end
      redirect_to contest, notice: 'Congratulations! Your solution was correct!'
      current_user.solved ||= []
      current_user.solved << ["dojo#{contest.puzzle_ident}_level#{level}", Time.now]
      current_user.save
    else
      

      if perf != -1
        if ENV["RAILS_ENV"] == "production"
        if false
        Pony.mail(
          :to => 'rafal.dittwald@gmail.com', :cc => 'james.nvc@gmail.com',
          :from => 'dojobot@hackeracademy.org',
          :subject => "#{perf.round(2)} #{current_user.name} P#{level} at #{Time.now}")
        end
        end
        redirect_to contest, alert: "Sorry, your solution was not good enough. P=#{perf.round(2)}"
      else
        redirect_to contest, alert: 'Sorry, your solution was incorrect'
      end
    end
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest = Contest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(params[:contest])

    respond_to do |format|
      if @contest.save
        format.html { redirect_to(@contest, :notice => 'Contest was successfully created.') }
        format.xml  { render :xml => @contest, :status => :created, :location => @contest }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contests/1
  # PUT /contests/1.xml
  def update
    @contest = Contest.find(params[:id])

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to(@contest, :notice => 'Contest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.xml
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end
end


