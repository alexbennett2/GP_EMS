require 'fileutils'

class ArticlesController < ApplicationController
	def index
		@articles = Article.all
	end

	def show
		@article = Article.find(params[:id])
	end

	def new
		@article = Article.new
	end
	def edit
		@article = Article.find(params[:id])
	end
	def create
				puts "=========================================="
		puts "=========================================="
		puts "=========================================="
		puts params[:bvin]
				puts "=========================================="
		puts "=========================================="
		puts "=========================================="
		@article = Article.new(params[:article])

		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

	def update
		@article = Article.find(params[:id])

		if @article.update(article_params)
			redirect_to @article
		else
			render 'edit'
		end
	end

	def destroy
		@article = Article.find(params[:id])
		@article.destroy

		redirect_to articles_path
	end

	# def analysis
	# 	render 'analysis'
	# 	# system("C:/Users/35317/Documents/Energy Efficieny Analytics Team/blog/script/create_DOE_prototype_building/tests/create_DEO_prototypes_simplified_Testdp.rb")
		
	# 	# script/runner script/create_DOE_prototype_building/tests/create_DEO_prototypes_simplified_Testdp.rb
	# end

	def action
		puts "=========================================="
		puts "=========================================="
		puts "=========================================="
		puts params
		puts "=========================================="
		puts "=========================================="
		puts "=========================================="
		# input1 = "gui_selection_building_type = " + params[:btype]
		# input2 = "gui_selection_vintage = " + params[:bvin]
		# input3 = "gui_selection_weather = " + params[:bweather]
		# input1 = params['btype']
		# input2 = params['bvin']
		# input3 = params['bweather']
		inputs = ["gui_selection_building_type = 'Small Office'", "gui_selection_weather = 'Athens'", \
			"gui_selection_vintage = 'Post 1980'"]
		# inputs = [input1,input2,input3]
		finds = ["gui_selection_building_type =", "gui_selection_weather =","gui_selection_vintage ="]
		file_name = 'script/create_DOE_prototype_building/tests/create_DOE_prototypes_simplified_Testdp.rb'
		finds.each_with_index do |find, index|
			lines = IO.readlines(file_name).map do |line|
					if line.include? find
						inputs[index]
					else
						line
					end
			end

			File.open(file_name, 'w') do |file|
				file.puts lines
			end
		end


		system("ruby 'script/create_DOE_prototype_building/tests/create_DOE_prototypes_simplified_Testdp.rb'")
		oldname = 'script/create_DOE_prototype_building/tests/NewModel.osm'
		newname = 'script/create_DOE_prototype_building/tests/OldModel.osm'
		FileUtils.cp(oldname,newname)

		render 'analysis'
	end


	private
		def article_params
			params.require(:article).permit(:btype, :bvin, :bweather)			
		end
end
