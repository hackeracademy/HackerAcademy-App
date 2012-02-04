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
    @num_probs = @contest.puzzle_ident == 3 ? 3 : 2
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

    @max_time_allowed = 120

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
        return
      end
    elsif contest_ident == 3
      unless (0..3).member? @level
        redirect_to @contest, alert: "Invalid level"
        return
      end
      @max_time_allowed = case @level
                          when 0 then 120
                          when 1 then 120
                          when 2 then 300
                          when 3 then 600
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
    elsif contest_ident == 3
      aes = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
      aes.encrypt
      aes.pkcs5_keyivgen(ENV['ENC_PASS'] || "foobar",
                         ENV['ENC_SALT'] || "sodiumcl")
      cipher =  aes.update(@prob[:plaintext])
      cipher << aes.final
      session[:soln] = cipher.unpack('H*').join
      msg = ''
    end
    key = ENV['HMAC_KEY'] || "derp"
    session[:key] = OpenSSL::HMAC.hexdigest('sha256', msg, key)

    render problem
  end

  def solution
    contest = Contest.find(params[:contest])
    correct = false
    perf = -1

    if contest.puzzle_ident == 3
      session.delete :key

      time_elapsed = Time.now.to_i - session[:time]
      session.delete :time

      level = params[:level]
      max_time_allowed = case level
                          when 0 then 120
                          when 1 then 120
                          when 2 then 300
                          when 3 then 600
                          else 120
                          end
      if time_elapsed > max_time_allowed
        redirect_to contest,
          alert: "Sorry, you took too long with your answer (#{time_elapsed} seconds)"
        return
      end

      begin
        aes = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
        aes.decrypt
        aes.pkcs5_keyivgen(ENV['ENC_PASS'] || "foobar",
                           ENV['ENC_SALT'] || "sodiumcl")
        our_plain =  aes.update(session[:soln].split.pack('H*'))
        our_plain << aes.final
      rescue OpenSSL::Cipher::CipherError => e
        redirect_to contest,
          alert: "Something funny happened there, try again"
        return
      ensure
        session.delete :soln
      end

      correctp = ContestsHelper::Dojo3.verify_puzzle(level.to_i,
                                                     our_plain,
                                                     params[:solution])
      if correctp
        if ENV["RAILS_ENV"] == "production"
          Pony.mail(
            :to => 'rafal.dittwald@gmail.com', :cc => 'jiang.d.han@gmail.com',
            :from => 'dojobot@hackeracademy.org',
            :subject => "#{current_user.name} has solved problem #{level} at #{Time.now}")
        end
        redirect_to contest, notice: 'Congratulations! Your solution was correct!'
        current_user.solved ||= []
        current_user.solved << ["dojo#{contest.puzzle_ident}_level#{level}", Time.now]
        current_user.save
      else
        redirect_to contest, alert: 'Sorry, your solution was incorrect'
      end
      return
    elsif contest.puzzle_ident == 2
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
        if true
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
      if perf != -1
        redirect_to contest, notice: "Congratulations! Your solution was good enough! #{perf.round(2)}"
      else
        redirect_to contest, notice: 'Congratulations! Your solution was correct!'
      end
      current_user.solved ||= []
      current_user.solved << ["dojo#{contest.puzzle_ident}_level#{level}", Time.now]
      current_user.save
    else


      if perf != -1
        if ENV["RAILS_ENV"] == "production"
        if true
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


