require 'openssl'
require 'cgi'

class ContestsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_user!, :except => [:show, :index]
  authorize_resource except: [:problem, :solution]
  skip_authorization_check only: [:problem, :solution]

  @@problems ||= {}

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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  def problem
    @contest = Contest.find(params[:contest_id])
    contest_ident = @contest.puzzle_ident
    @level = params[:level]

    if contest_ident == 1
      puzzle1_length = 200
      puzzle1_words = 10

      puzzle2_length = 20
      puzzle2_words = 1

      puzzle3_length = 100
      puzzle3_words = 5
      if @level == '0'
        @prob = ContestsHelper::Level1.generate_level0(
          puzzle1_length, puzzle1_words
        )
        @puzzle = <<-EOS
        <p>Find the following words in the text string and give the numerical
          indicies in alphabetical order, seperated by commas (e.g 17, 4, 2).
        </p>
        Needles:
        <div class="data"><code>#{@prob[:words].map{|w| "#{w}"}.join('<br>')}</code></div>
        Haystack:
        <div class="data"><code>#{@prob[:puzzle]}</code></div>
        EOS
      elsif @level == '1'
        @prob = ContestsHelper::Level1.generate_level1(
          puzzle2_length, puzzle2_words
        )
        @puzzle = <<-EOS
        <p>Find the following words in the text string and give the numerical
           indicies in alphabetical order as row,col comma-seperated pairs, with
           each pair seperated by semicolons (e.g 5,6; 1,10; 8,2).
        </p>
        Needles:
        <ul>#{@prob[:words].map{|w| "<li>#{w}</li>"}.join('')}</ul>
        Haystack:
        <code class="problem">#{@prob[:puzzle]}</code>
        EOS
      elsif @level == '2'
        @prob = ContestsHelper::Level1.generate_level1(
          puzzle3_length, puzzle3_words
        )
        @puzzle = <<-EOS
        <p>Find the following words in the text string and give the numerical
          indicies in alphabetical order as row,col comma-seperated pairs, with
          each pair seperated by semicolons (e.g 5,6; 1,10; 8,2). This time,
          however, they words will have up to one character wrong!
        </p>
        <ul>#{@prob[:words].map{|w| "<li>#{w}</li>"}.join('')}</ul>
        <textarea><code class="problem">#{@prob[:puzzle]}</code></textarea>
        EOS
      else
        redirect_to @contest, alert: "Invalid level"
        return
      end
      session[:time] = Time.now.to_i
      msg = @prob[:puzzle] + @prob[:words].join('')
      key = ENV['HMAC_KEY']
      session[:key] = OpenSSL::HMAC.hexdigest('sha256', msg, key)
      render action: :problem
    else
      redirect_to @contest, alert: "Invalid contest"
    end
  end

  def solution
    contest = Contest.find(params[:contest])
    puzzle = params[:puzzle].gsub('N', "\n").gsub('-', ' ')
    words = params[:words].split('+')
    prob = {puzzle: puzzle, words: words}
    msg = puzzle + words.join('')
    key = ENV['HMAC_KEY']
    hmac = OpenSSL::HMAC.hexdigest('sha256', msg, key)
    if hmac != session[:key]
      redirect_to contest, alert: 'Cheating detected...'
      return
    end
    session.delete :key
    level = params[:level]
    time_elapsed = Time.now.to_i - session[:time]
    session.delete :time
    if time_elapsed > 600
      redirect_to contest,
        alert: "Sorry, you took too long with your answer (#{time_elapsed} seconds)"
      return
    end
    if contest.puzzle_ident == 1
      if level == '0'
        soln = params[:solution].split(/\s*,\s*/).map(&:to_i)
        if soln.length != prob[:words]
          correct = false
        else
          correct = ContestsHelper::Level1.verify_level0(
            Hash[*prob[:words].sort.zip(soln).flatten], prob[:puzzle]
          )
        end
      elsif level == '1'
        soln = params[:solution].split(/\s*;\s*/).map do |pair|
          pair.split(/\s*,\s*/).map(&:to_i)
        end
        if soln.length != prob[:words]
          Rails.logger.debug("Wrong length")
          correct = false
        else
          soln = prob[:words].sort.zip(soln)
          Rails.logger.debug(prob)
          correct = ContestsHelper::Level1.verify_level1(
            soln.inject({}) {|h,e| h[e.first] = e.second; h}, prob[:puzzle]
          )
        end
      elsif level == '2'
        soln = params[:solution].split(/\s*;\s*/).map do |pair|
          pair.split(/\s*,\s*/).map(&:to_i)
        end
        if soln.length != prob[:words]
          correct = false
        else
          soln = prob[:words].sort.zip(soln)
          correct = ContestsHelper::Level1.verify_level2(
            soln.inject({}) {|h,e| h[e.first] = e.second; h}, prob[:puzzle]
          )
        end
      end
    end
    if correct
      render action: :solution
    else
      redirect_to contest, alert: 'Sorry, your solution was incorrect'
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
