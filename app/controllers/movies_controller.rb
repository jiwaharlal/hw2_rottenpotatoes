class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    paramsBonus = Hash.new
    if params[:sort] == nil and not session[:sort] == nil
      paramsBonus[:sort] = "by_name" # session[:sort]
    else
      session[:sort] = params[:sort]
    end
    if params[:ratings] == nil
      if session[:ratings] == nil
	ratings = Hash.new
	Movie.availableRatings.each do |rating|
	  ratings[rating] = 1
	end
	paramsBonus[:ratings] = ratings
      else
	paramsBonus[:ratings] = session[:ratings]
      end
    else
      session[:ratings] = params[:ratings]
    end
    
    if not paramsBonus.empty?
      flash.keep
      redirect_to movies_path params.merge(paramsBonus)
    end
    
    @selectedRatings = Array.new
    if params[:ratings] != nil
      @selectedRatings += params[:ratings].keys
    end
    
    if not @selectedRatings.empty?
      ratingsStr = "rating in #{@selectedRatings}".sub('[', '(').sub(']', ')')
      while ratingsStr.include? '"'
	ratingsStr.sub!('"', "'")
      end
      @movies = Movie.find(:all, :conditions => [ratingsStr])
    else
      @movies = Movie.all
    end
    @sortMethod = params[:sort]
    case params[:sort]
    when "by_name"
      @movies.sort! { |a,b| a.title.downcase <=> b.title.downcase }
      @title_class = "hilite"
    when "by_date"
      @movies.sort! { |a,b| a.release_date <=> b.release_date }
      @date_class = "hilite"
    end

    @all_ratings = Movie.availableRatings
  end

  #def new
    # default: render 'new' template
  #end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
