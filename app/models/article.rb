class Article < ActiveRecord::Base
	# validates :title, presence: true,
	# 				  length: { minimum: 5 }

	validates :btype, presence: true,
					  length: { minimum: 5}
	validates :bvin, presence: true,
					  length: { minimum: 5}
  	validates :bweather, presence: true,
					  length: { minimum: 5}				  

end
